require 'spec_helper'

RSpec.describe Terradactyl::Terraform::Commands::Base do
  let(:install_error) do
    Terradactyl::Terraform::VersionManager::VersionManagerError
  end

  let(:install_error_msg) do
    Terradactyl::Terraform::VersionManager::ERROR_MISSING
  end

  before(:all) do
    Terradactyl::Terraform::VersionManager.inventory.each do |_version, path|
      FileUtils.rm path
    end
  end

  after(:all) do
    Terradactyl::Terraform::VersionManager.inventory.each do |_version, path|
      FileUtils.rm path
    end
  end

  context 'when no versions are installed' do
    describe '#execute' do
      it 'raises an error ' do
        expect { subject.execute }.to raise_error(
          install_error, /#{install_error_msg}/)
      end
    end
  end

  context 'initialization' do
    before(:all) do
      Terradactyl::Terraform::VersionManager.install('0.11.14')
      Terradactyl::Terraform::VersionManager.version = '0.11.14'
    end

    describe '#execute' do
      it 'exits with error 127' do
        silence { expect(subject.execute).to eq(127) }
      end

      it 'outputs usage info' do
        expect { subject.execute }.to output(/Usage: terraform/).to_stdout
      end
    end

    describe '#options' do
      it 'accepts new configurations' do
        expect(subject.options.quiet = true).to be_truthy
      end
    end

    describe '#execute with capture' do
      let(:result) { subject.execute(capture: true) }

      it 'returns an Array of process info' do
        expect(result).to be_a(OpenStruct)
        expect(result.stdout).to match(/Usage: terraform/)
        expect(result.stderr).to be_empty
        expect(result.exitstatus).to eq(127)
      end
    end

    describe '#execute with quiet' do
      it 'does not output usage info' do
        subject.options.quiet = true
        expect { subject.execute }.not_to output(/Usage: terraform/).to_stdout
      end
    end

    describe '#execute with echo' do
      it 'outputs the cmd args' do
        subject.options.echo = true
        expect { subject.execute }.to output(/Executing: \[.*\]/).to_stdout
      end
    end

    describe '#execute with invalid args' do
      it 'raises an exception' do
        subject.options.foo = true
        expect { subject.execute }.to raise_error(RuntimeError, /Invalid arguments/)
      end
    end
  end

  context 'alternate initialization' do
    describe '.execute' do
      let(:executed) { described_class.execute }

      it 'executes the command immediately' do
        silence { expect(executed).to eq(127) }
      end
    end

    describe '.execute with capture' do
      let(:captured) { described_class.execute(capture: true) }

      it 'executes the command immediately (no output)' do
        expect(captured).to be_a(OpenStruct)
        expect(captured.stdout).to match(/Usage: terraform/)
        expect(captured.stderr).to be_empty
        expect(captured.exitstatus).to eq(127)
      end
    end
  end
end
