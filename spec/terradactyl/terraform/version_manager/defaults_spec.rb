require 'spec_helper'

RSpec.describe Terradactyl::Terraform::VersionManager::Defaults do
  before(:all) do
    Terradactyl::Terraform::VersionManager.managed_binaries.each do |path|
      FileUtils.rm path
    end
  end

  after(:each) do
    subject.reset!
  end

  let(:binary) do
    Terradactyl::Terraform::VersionManager::Defaults::DEFAULT_BINARY
  end

  let(:version) do
    Terradactyl::Terraform::VersionManager::Defaults::DEFAULT_VERSION
  end

  let(:autoinstall) do
    Terradactyl::Terraform::VersionManager::Defaults::DEFAULT_AUTOINSTALL
  end

  let(:install_dir) do
    Terradactyl::Terraform::VersionManager::Defaults::DEFAULT_INSTALL_DIR
  end

  let(:downloads_url) do
    Terradactyl::Terraform::VersionManager::Defaults::DEFAULT_DOWNLOADS_URL
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
    describe '#binary' do
      it 'returns the default value' do
        expect(subject.binary).to eq(binary)
      end
    end

    describe '#version' do
      it 'returns the default value' do
        expect(subject.version).to eq(version)
      end
    end

    describe '#autoinstall' do
      it 'returns the default value' do
        expect(subject.autoinstall).to eq(autoinstall)
      end
    end

    describe '#install_dir' do
      it 'returns the default value' do
        expect(subject.install_dir).to eq(install_dir)
      end
    end

    describe '#downloads_url' do
      it 'returns the default value' do
        expect(subject.downloads_url).to eq(downloads_url)
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
    describe '#binary=' do
      it 'ignores empty values' do
        subject.binary = ''
        expect(subject.binary).to eq(binary)
      end
      it 'ignores nil values' do
        subject.binary = nil
        expect(subject.binary).to eq(binary)
      end
      it 'ignores invalid path values' do
        subject.binary = 'some/fake/path'
        expect(subject.binary).to eq(binary)
      end
    end

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
        subject.binary = '0.0'
        expect(subject.version).to eq(version)
      end
    end

    describe '#autoinstall=' do
      it 'ignores empty values' do
        subject.autoinstall = ''
        expect(subject.autoinstall).to eq(autoinstall)
      end
      it 'ignores nil values' do
        subject.autoinstall = nil
        expect(subject.autoinstall).to eq(autoinstall)
      end
      it 'ignores invalid strings' do
        subject.autoinstall = 'true'
        expect(subject.autoinstall).to eq(autoinstall)
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

    describe '#downloads_url=' do
      it 'ignores empty values' do
        subject.downloads_url = ''
        expect(subject.downloads_url).to eq(downloads_url)
      end
      it 'ignores nil values' do
        subject.downloads_url = nil
        expect(subject.downloads_url).to eq(downloads_url)
      end
      it 'ignores invalid url values' do
        subject.downloads_url = 'some/garbage/path'
        expect(subject.downloads_url).to eq(downloads_url)
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
