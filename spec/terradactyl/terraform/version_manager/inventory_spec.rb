require 'spec_helper'

RSpec.describe Terradactyl::Terraform::VersionManager::Inventory do

  before(:all) do
    @install_dir   = Terradactyl::Terraform::VersionManager.install_dir
    @test_versions = %w[0.11.14 0.12.2]
    @test_binaries = @test_versions.map { |v| "#{@install_dir}/terraform-#{v}" }
  end

  let(:subject)     { described_class.new }
  let(:install_dir) { @install_dir }

  let(:inventory_error) do
    Terradactyl::Terraform::VersionManager::InventoryError
  end

  let(:inventory_error_missing) do
    Terradactyl::Terraform::VersionManager::Inventory::ERROR_VERSION_MISSING
  end

  let(:test_versions) { @test_versions }
  let(:test_binaries) { @test_binaries }

  describe '#install_dir' do
    it 'returns the installation directory' do
      expect(subject.install_dir).to eq(install_dir)
    end
  end

  context 'when NONE are installed' do
    describe '#binaries' do
      it 'returns an empty Array' do
        expect(subject.binaries).to be_a(Array)
        expect(subject.binaries).to be_empty
      end
    end

    describe '#versions' do
      it 'returns an empty Array' do
        expect(subject.versions).to be_a(Array)
        expect(subject.versions).to be_empty
      end
    end

    describe '#manifest' do
      it 'returns an empty Hash' do
        expect(subject.manifest).to be_a(Hash)
        expect(subject.manifest).to be_empty
      end
    end

    describe '#latest' do
      it 'returns NilClass' do
        expect(subject.latest).to be_nil
      end
    end

    describe '#validate' do
      it 'raises an exception' do
        expect {subject.validate('0.0.0') }.to raise_error(
          inventory_error, /#{inventory_error_missing}/)
      end
    end

    describe '#[]' do
      it 'returns NilClass' do
        expect(subject['0.0.0']).to be_nil
      end
    end

    describe '#any?' do
      it 'returns false' do
        expect(subject.any?).to be_falsey
      end
    end
  end

  context 'when SOME are installed' do

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

    describe '#binaries' do
      it 'returns a list of managed Terraform binaries' do
        expect(subject.binaries).to be_a(Array)
        expect(subject.binaries).to_not be_empty
        expect(subject.binaries).to eq(test_binaries)
      end
    end

    describe '#versions' do
      it 'returns a list of versions' do
        expect(subject.versions).to be_a(Array)
        expect(subject.versions).to_not be_empty
        expect(subject.versions).to eq(test_versions)
      end
    end

    describe '#manifest' do
      it 'returns version to binary map' do
        expect(subject.manifest).to be_a(Hash)
        expect(subject.manifest).to_not be_empty
        expect(subject.manifest).to eq(Hash[test_versions.zip(test_binaries)])
      end
    end

    describe '#latest' do
      it 'returns the latest semantic version' do
        expect(subject.latest).to_not be_nil
        expect(subject.latest).to eq(test_versions.last)
      end
    end

    describe '#validate' do
      it 'returns the binary path' do
        expect(subject.validate(test_versions.last)).to eq(test_binaries.last)
      end
    end

    describe '#[]' do
      it 'returns the binary path' do
        expect(subject[test_versions.last]).to eq(test_binaries.last)
      end
    end

    describe '#any' do
      it 'returns true' do
        expect(subject.any?).to be_truthy
      end
    end
  end
end
