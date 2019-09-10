require 'spec_helper'

RSpec.describe Terradactyl::Terraform::VersionManager do
  before(:all) do
    @install_dir   = Terradactyl::Terraform::VersionManager.install_dir
    @test_versions = %w[0.11.14 0.12.2]
    @test_binaries = @test_versions.map { |v| "#{@install_dir}/terraform-#{v}" }
  end

  after(:all) do
    Terradactyl::Terraform::VersionManager.binaries.each do |file|
      FileUtils.rm_rf file
    end
    Terradactyl::Terraform::VersionManager.reset!
  end

  let(:install_dir) { @install_dir }

  let(:install_error) do
    Terradactyl::Terraform::VersionManager::VersionManagerError
  end

  let(:install_error_msg) do
    Terradactyl::Terraform::VersionManager::ERROR_MISSING
  end

  let(:inventory_error) do
    Terradactyl::Terraform::VersionManager::InventoryError
  end

  let(:inventory_error_missing) do
    Terradactyl::Terraform::VersionManager::Inventory::ERROR_VERSION_MISSING
  end

  let(:test_versions) { @test_versions }
  let(:test_binaries) { @test_binaries }

  let(:install_dir) do
    Terradactyl::Terraform::VersionManager::Defaults::DEFAULT_INSTALL_DIR
  end

  let(:downloads_url) do
    Terradactyl::Terraform::VersionManager::Defaults::DEFAULT_DOWNLOADS_URL
  end

  let(:releases_url) do
    Terradactyl::Terraform::VersionManager::Defaults::DEFAULT_RELEASES_URL
  end

  describe '#latest' do
    it 'returns the very latest version of Terraform' do
      expect(subject.latest).to match(/\d\.\d{2}\.\d/)
    end
  end

  context 'management' do
    context 'when NONE installed' do
      before(:all) do
        Terradactyl::Terraform::VersionManager.reset!
        @test_binaries.each { |path| FileUtils.rm_rf path }
      end

      after(:all) do
        Terradactyl::Terraform::VersionManager.reset!
        @test_binaries.each { |path| FileUtils.rm_rf path }
      end

      describe '#install' do
        after(:each) do
          Terradactyl::Terraform::VersionManager.reset!
          @test_binaries.each { |path| FileUtils.rm_rf path }
        end

        context 'when no version is specified' do
          let(:semver) { '0.11.14' }

          it 'installs the default version' do
            Terradactyl::Terraform::VersionManager.version = semver
            expect(subject.install).to be_truthy
            expect(File.exist?(subject[semver])).to be_truthy
            expect(File.stat(subject[semver]).mode).to eq(33261)
            cmd_output =`#{subject[semver]}`
            exit_code  = $?.exitstatus
            expect(cmd_output).to match(/Usage: terraform/)
            expect(exit_code).to eq(127)
          end
        end

        context 'when a version is specified' do
          it 'installs the specified version of Terraform' do
            test_versions.each do |semver|
              expect(subject.install(semver)).to be_truthy
              expect(File.exist?(subject[semver])).to be_truthy
              expect(File.stat(subject[semver]).mode).to eq(33261)
              cmd_output =`#{subject[semver]}`
              exit_code  = $?.exitstatus
              expect(cmd_output).to match(/Usage: terraform/)
              expect(exit_code).to eq(127)
            end
          end
        end
      end

      describe '#binary' do
        it 'raises an exception' do
          expect { subject.binary }.to raise_error(
            install_error, /#{install_error_msg}/)
        end
      end

      describe '#remove' do
        it 'returns false for a specified version of Terraform' do
          test_versions.each do |semver|
            expect(subject.remove(semver)).to be_falsey
          end
        end
      end
    end

    context 'when SOME installed' do
      before(:all) do
        Terradactyl::Terraform::VersionManager.reset!
        @test_versions.each do |semver|
          Terradactyl::Terraform::VersionManager.install(semver)
        end
      end

      after(:all) do
        Terradactyl::Terraform::VersionManager.reset!
      end

      describe '#binary' do
        context 'when version is NOT selected' do
          it 'returns the latest binary in inventory' do
            expect(subject.binary).to eq(test_binaries.last)
          end
        end

        context 'when version is selected' do
          context 'when version is available' do
            it 'returns the specified version binary' do
              Terradactyl::Terraform::VersionManager.version = test_versions.first
              expect(subject.binary).to eq(test_binaries.first)
            end
          end

          context 'when version is NOT available' do
            it 'raises an exception' do
              Terradactyl::Terraform::VersionManager.version = '0.0.0'
              expect { subject.binary }.to raise_error(
                inventory_error, /#{inventory_error_missing}/)
            end
          end
        end
      end

      describe '#remove' do
        context 'when a version is specified' do
          it 'removes the specified version of Terraform' do
            test_versions.each do |semver|
              binary = subject[semver]
              expect(File.exist?(binary)).to be_truthy
              expect(subject.remove(semver)).to be_truthy
              expect(File.exist?(binary)).to be_falsey
            end
          end
        end

        context 'when no version is specified' do
          before do
            @semver = '0.11.14'
            Terradactyl::Terraform::VersionManager.reset!
            Terradactyl::Terraform::VersionManager.install(@semver)
          end

          it 'removes the default version' do
            Terradactyl::Terraform::VersionManager.version = @semver
            binary = subject[@semver]
            expect(File.exist?(binary)).to be_truthy
            expect(subject.remove).to be_truthy
            expect(File.exist?(binary)).to be_falsey
          end
        end
      end
    end
  end

  context 'configuration' do
    before(:each) do
      @temp_dir = Dir.mktmpdir('terradactyl')
    end

    after(:each) do
      FileUtils.rm_rf @temp_dir
      subject.reset!
    end

    it 'responds to requests for options' do
      expect(subject.install_dir).to eq(install_dir)
      expect(subject.downloads_url).to eq(downloads_url)
      expect(subject.releases_url).to eq(releases_url)
    end

    describe 'block configuration' do
      it 'accepts a block of configuration options' do
        expect(subject.options { |c| c.install_dir = @temp_dir}).to eq(@temp_dir)
        expect(subject.install_dir).to eq(@temp_dir)
      end
    end

    describe 'direct configuration' do
      it 'accepts a block of configuration options' do
        expect(subject.install_dir = @temp_dir).to eq(@temp_dir)
        expect(subject.install_dir).to eq(@temp_dir)
      end
    end
  end

  context 'inventory' do
    before(:all) do
      @test_versions.each do |semver|
        Terradactyl::Terraform::VersionManager.install(semver)
      end
    end

    after(:all) do
      @test_versions.each do |semver|
        Terradactyl::Terraform::VersionManager.remove(semver)
      end
    end

    describe '#inventory' do
      it 'returns an Inventory object' do
        expect(subject.inventory).to be_a(Terradactyl::Terraform::VersionManager::Inventory)
      end
    end

    describe '#[]' do
      it 'returns the binary path' do
        expect(subject[test_versions.last]).to eq(test_binaries.last)
      end
    end

    describe 'versions' do
      it 'returns a list of installed versions' do
        expect(subject.versions).to be_a(Array)
        expect(subject.versions).to_not be_empty
        expect(subject.versions).to eq(test_versions)
      end
    end

    describe '#binaries' do
      it 'returns a list of managed Terraform binaries' do
        expect(subject.binaries).to be_a(Array)
        expect(subject.binaries).to_not be_empty
        expect(subject.binaries).to eq(test_binaries)
      end
    end

    describe '#any?' do
      it 'returns true if any binaries are installed' do
        expect(subject.any?).to be_truthy
      end
    end
  end

  context 'custom install_dir' do
    before(:all) do
      @temp_dir = Dir.mktmpdir('terradactyl')
      Terradactyl::Terraform::VersionManager.options do |option|
        option.install_dir = @temp_dir
      end
    end

    after(:all) do
      FileUtils.rm_rf @temp_dir
      described_class.reset!
    end

    describe '#install' do
      it 'installs the specified version of Terraform' do
        test_versions.each do |semver|
          expect(subject.install(semver)).to be_truthy
          expect(File.exist?(subject[semver])).to be_truthy
          expect(File.stat(subject[semver]).mode).to eq(33261)
          cmd_output =`#{subject[semver]}`
          exit_code  = $?.exitstatus
          expect(cmd_output).to match(/Usage: terraform/)
          expect(exit_code).to eq(127)
        end
      end
    end

    describe '#remove' do
      it 'removes the specified version of Terraform' do
        test_versions.each do |semver|
          binary = subject[semver]
          expect(File.exist?(binary)).to be_truthy
          expect(subject.remove(semver)).to be_truthy
          expect(File.exist?(binary)).to be_falsey
        end
      end
    end
  end
end
