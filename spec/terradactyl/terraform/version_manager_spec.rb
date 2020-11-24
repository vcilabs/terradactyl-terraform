require 'spec_helper'

RSpec.describe Terradactyl::Terraform::VersionManager do
  before(:all) do
    @install_dir   = Terradactyl::Terraform::VersionManager.install_dir
    @test_versions = %w[0.11.14 0.12.2]
    @test_binaries = @test_versions.map { |v| "#{@install_dir}/terraform-#{v}" }
    @expressed_versions = {
      '~> 0.11.14' => 'eq("0.11.15-oci")',
      '~> 0.11'    => 'be > "0.14"',
      '>= 0.12'    => 'be >= "0.12"',
      '< 0.12'     => 'be < "0.12"'
    }
  end

  after(:all) do
    Terradactyl::Terraform::VersionManager.binaries.each do |file|
      FileUtils.rm_rf file
    end
    Terradactyl::Terraform::VersionManager.reset!
  end

  let(:install_dir) { @install_dir }

  let(:version_manager_error) do
    Terradactyl::Terraform::VersionManager::VersionManagerError
  end

  let(:install_error_msg) do
    Terradactyl::Terraform::VersionManager::ERROR_MISSING
  end

  let(:inventory_error) do
    Terradactyl::Terraform::VersionManager::InventoryError
  end

  let(:invalid_version_error_msg) do
    Terradactyl::Terraform::VersionManager::ERROR_INVALID_VERSION_STRING
  end

  let(:inventory_error_missing) do
    Terradactyl::Terraform::VersionManager::Inventory::ERROR_VERSION_MISSING
  end

  let(:test_versions) { @test_versions }
  let(:test_binaries) { @test_binaries }
  let(:expressed_versions) { @expressed_versions }

  let(:install_dir) do
    Terradactyl::Terraform::VersionManager::Defaults::DEFAULT_INSTALL_DIR
  end

  let(:downloads_url) do
    Terradactyl::Terraform::VersionManager::Defaults::DEFAULT_DOWNLOADS_URL
  end

  let(:releases_url) do
    Terradactyl::Terraform::VersionManager::Defaults::DEFAULT_RELEASES_URL
  end

  describe '#current_version' do
    before(:each) do
      Terradactyl::Terraform::VersionManager.reset!
    end

    after(:each) do
      Terradactyl::Terraform::VersionManager.reset!
    end

    let(:semver) { '0.11.14' }
    let(:expver) { '~> 0.11.0' }
    let(:maxver) { '0.11.15-oci' }

    context 'when an explicit version is set' do
      it 'returns it' do
        Terradactyl::Terraform::VersionManager.version = semver
        expect(subject.current_version).to eq(semver)
      end
    end

    context 'when an expressed version is set' do
      it 'returns the calculated version' do
        Terradactyl::Terraform::VersionManager.version = expver
        expect(subject.current_version).to eq(maxver)
      end
    end
  end

  describe '#versions' do
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

    let(:local_versions)  { subject.versions }
    let(:remote_versions) { subject.versions(local: false) }

    context 'when no options' do
      it 'returns a list of locally installed versions' do
        expect(local_versions).to be_a(Array)
        expect(local_versions).to_not be_empty
        expect(local_versions).to include(test_versions.first)
        expect(local_versions).to include(test_versions.last)
      end
    end

    context 'when passed option, local: true' do
      it 'returns a list of locally installed versions' do
        expect(local_versions).to be_a(Array)
        expect(local_versions).to_not be_empty
        expect(local_versions).to include(test_versions.first)
        expect(local_versions).to include(test_versions.last)
      end
    end

    context 'when passed option, local: false' do
      it 'returns a list of locally installed versions' do
        expect(remote_versions()).to be_a(Array)
        expect(remote_versions).to_not be_empty
        expect(remote_versions).to include(test_versions.first)
        expect(remote_versions).to include(test_versions.last)
      end
    end
  end

  describe '#latest' do
    it 'returns the very latest version of Terraform' do
      expect(subject.latest).to match(/\d\.\d{2}\.\d/)
    end
  end

  describe '#resolve' do
    context 'when passed a bad version expression' do
      it 'raises an exception' do
        expect { subject.resolve(nil) }.to raise_error(
          version_manager_error, /#{invalid_version_error_msg}/)
        expect { subject.resolve('') }.to raise_error(
          version_manager_error, /#{invalid_version_error_msg}/)
        expect { subject.resolve('foo') }.to raise_error(
          version_manager_error, /#{invalid_version_error_msg}/)
        expect { subject.resolve('0') }.to raise_error(
          version_manager_error, /#{invalid_version_error_msg}/)
        expect { subject.resolve('0.') }.to raise_error(
          version_manager_error, /#{invalid_version_error_msg}/)
        expect { subject.resolve('0.0') }.to raise_error(
          version_manager_error, /#{invalid_version_error_msg}/)
        expect { subject.resolve('~>') }.to raise_error(
          version_manager_error, /#{invalid_version_error_msg}/)
        expect { subject.resolve('>') }.to raise_error(
          version_manager_error, /#{invalid_version_error_msg}/)
      end
    end

    context 'when passed a valid version expression' do
      it 'produces the expected version string' do
        expressed_versions.each do |exp, test|
          expect(subject.resolve(exp)).to eval(test)
        end
      end
    end
  end

  context 'management' do
    context 'when NONE installed' do
      before(:all) do
        Terradactyl::Terraform::VersionManager.reset!
        Terradactyl::Terraform::VersionManager.binaries.each do |file|
          FileUtils.rm_rf file
        end
      end

      after(:all) do
        Terradactyl::Terraform::VersionManager.reset!
        Terradactyl::Terraform::VersionManager.binaries.each do |file|
          FileUtils.rm_rf file
        end
      end

      describe '#install' do
        after(:each) do
          Terradactyl::Terraform::VersionManager.reset!
          Terradactyl::Terraform::VersionManager.binaries.each do |file|
            FileUtils.rm_rf file
          end
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

        context 'when a version is expressed' do
          it 'installs the expressed version of Terraform' do
            expressed_versions.each do |exp, test|
              res = Terradactyl::Terraform::VersionManager.resolve(exp)
              expect(subject.install(exp)).to be_truthy
              expect(File.exist?(subject[res])).to be_truthy
              expect(File.stat(subject[res]).mode).to eq(33261)
              cmd_output =`#{subject[res]}`
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
            version_manager_error, /#{install_error_msg}/)
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
              Terradactyl::Terraform::VersionManager.version = '0.11.1'
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
        expect(subject.versions).to include(test_versions.first)
        expect(subject.versions).to include(test_versions.last)
      end
    end

    describe '#binaries' do
      it 'returns a list of managed Terraform binaries' do
        expect(subject.binaries).to be_a(Array)
        expect(subject.binaries).to_not be_empty
        expect(subject.binaries).to include(test_binaries.first)
        expect(subject.binaries).to include(test_binaries.last)
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
