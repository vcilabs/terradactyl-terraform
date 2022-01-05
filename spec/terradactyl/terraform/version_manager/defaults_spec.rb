require 'spec_helper'

RSpec.describe Terradactyl::Terraform::VersionManager::Defaults do
  before(:all) do
    Terradactyl::Terraform::VersionManager.binaries.each do |file|
      FileUtils.rm_rf file
    end
    Terradactyl::Terraform::VersionManager.reset!
  end

  after(:all) do
    Terradactyl::Terraform::VersionManager.binaries.each do |file|
      FileUtils.rm_rf file
    end
    Terradactyl::Terraform::VersionManager.reset!
  end

  let(:version) do
    Terradactyl::Terraform::VersionManager::Defaults::DEFAULT_VERSION
  end

  let(:install_dir) do
    Terradactyl::Terraform::VersionManager::Defaults::DEFAULT_INSTALL_DIR
  end

  let(:releases_url) do
    Terradactyl::Terraform::VersionManager::Defaults::DEFAULT_RELEASES_URL
  end

  describe '#reset!' do
    it 'reloads defaults' do
      subject.version = '0.12.6'
      subject.reset!
      expect(subject.version).to eq(version)
    end
  end

  context 'simple initialization' do
    describe '#version' do
      it 'returns the default value' do
        expect(subject.version).to eq(version)
      end
    end

    describe '#install_dir' do
      it 'returns the default value' do
        expect(subject.install_dir).to eq(install_dir)
      end
    end

    describe '#releases_url' do
      it 'returns the default value' do
        expect(subject.releases_url).to eq(releases_url)
      end
    end
  end

  context 'post-init configuration' do
    before { @temp_dir = Dir.mktmpdir('terradactyl') }
    after  { FileUtils.rm_rf @temp_dir }

    describe '#install_dir=' do
      it 'sets the value' do
        subject.install_dir = @temp_dir
        expect(subject.install_dir).to eq(@temp_dir)
      end
    end
  end

  context 'provides nil-safe defaults' do
    describe '#version=' do
      it 'ignores empty values' do
        subject.version = ''
        expect(subject.version).to eq(version)
      end
      it 'ignores nil values' do
        subject.version = nil
        expect(subject.version).to eq(version)
      end
      it 'ignores invalid strings' do
        subject.version = 'invalid'
        expect(subject.version).to eq(version)
      end
    end

    describe '#install_dir=' do
      it 'ignores empty values' do
        subject.install_dir = ''
        expect(subject.install_dir).to eq(install_dir)
      end
      it 'ignores nil values' do
        subject.install_dir = nil
        expect(subject.install_dir).to eq(install_dir)
      end
      it 'ignores invalid path values' do
        subject.install_dir = 'some/fake/path'
        expect(subject.install_dir).to eq(install_dir)
      end
      it 'expands valid path values' do
        subject.install_dir = '~/'
        expect(subject.install_dir).not_to eq('~/')
        expect(subject.install_dir).to eq(File.expand_path('~/'))
      end
    end

    describe '#releases_url=' do
      it 'ignores empty values' do
        subject.releases_url = ''
        expect(subject.releases_url).to eq(releases_url)
      end
      it 'ignores nil values' do
        subject.releases_url = nil
        expect(subject.releases_url).to eq(releases_url)
      end
      it 'ignores invalid url values' do
        subject.releases_url = 'some/garbage/path'
        expect(subject.releases_url).to eq(releases_url)
      end
    end
  end
end
