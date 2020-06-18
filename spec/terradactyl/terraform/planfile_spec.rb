require 'spec_helper'

include Terradactyl::Terraform

RSpec.describe 'Working with Terraform PlanFiles' do
  context 'when binary is Terraform 0.11.x' do
    before(:all) do
      @stack_name    = 'stack_b'
      @stack_dir     = "stacks/#{@stack_name}"
      @plan_path     = "stacks/#{@stack_name}/#{@stack_name}.tfout"
      @artifacts     = terraform_cmd_artifacts(@stack_dir)
      @artifacts.each_pair { |_k,v| FileUtils.rm_rf(v) if File.exist?(v) }

      Terradactyl::Terraform::VersionManager.binaries.each do |file|
        FileUtils.rm_rf file
      end
      Terradactyl::Terraform::VersionManager.reset!

      @version       = '0.11.14'
      @plan_checksum = '134588621b1cba262e384c2697c9060331ca7d2e'
      @options_init  = Commands::Options.new({quiet: true})
      @options_plan  = Commands::Options.new({
        quiet: true,
        detailed_exitcode: true,
        state: @artifacts.apply,
        out: @artifacts.plan
      })

      ENV['TF_PLUGIN_CACHE_DIR'] = File.expand_path('~/.terraform.d/plugins')

      VersionManager.install(@version)

      Commands::Init.execute(dir_or_plan: @stack_dir, options: @options_init)
      Commands::Plan.execute(dir_or_plan: @stack_dir, options: @options_plan)
    end

    after(:all) do
      @artifacts.each_pair { |_k,v| FileUtils.rm_rf(v) if File.exist?(v) }

      Terradactyl::Terraform::VersionManager.binaries.each do |file|
        FileUtils.rm_rf file
      end
      Terradactyl::Terraform::VersionManager.reset!
    end

    describe Terradactyl::Terraform::Rev011::PlanFileParser do
      context 'initialization' do
        describe '#load' do
          let(:instance) { described_class.load(@plan_path) }

          it 'loads and parses a terraform plan file' do
            expect(instance).to be_a(described_class)
            expect(instance).to respond_to(:checksum)
          end
        end
      end

      context 'initialized' do
        let(:instance) { described_class.load(@plan_path) }

        describe '#plan_path' do
          it 'shows the path to the plan' do
            expect(instance.plan_path).to eq(@plan_path)
          end
        end

        describe '#data' do
          it 'emits a string' do
            expect(instance.data).to be_a(String)
          end
        end

        describe '#checksum' do
          let(:sha1sum_re) { /(?:[0-9a-f]){40}/ }

          it 'emits a checksum of the plan content' do
            expect(instance.checksum).to match(/#{sha1sum_re}/)
            expect(instance.checksum).to eq(@plan_checksum)
          end
        end
      end
    end

    describe Terradactyl::Terraform::PlanFile do
      let(:parser) { Terradactyl::Terraform::Rev011::PlanFileParser }
      let(:instance) do
        described_class.new(plan_path: @plan_path, parser: parser )
      end
      let(:plan_output) { 'some rando text' }
      let(:err_no_plan_output) { described_class::WARN_NO_PLAN_OUTPUT }

      context 'initialization' do
        context 'when plan_path is a non-existent file' do
          let(:parse_error) { Terradactyl::Terraform::PlanFileParserError }
          let(:instance) do
            described_class.new(plan_path: 'non-existent.tfout', parser: parser )
          end

          it 'rescues and captures a parse error' do
            expect(instance).to be_a(described_class)
            expect(instance.data).to be_a(parse_error)
          end
        end

        it 'loads and parses a terraform plan file' do
          expect(instance).to be_a(described_class)
          expect(instance).to respond_to(:checksum)
        end

        describe '#checksum' do
          let(:sha1sum_re) { /(?:[0-9a-f]){40}/ }
          it 'emits a checksum of the plan content' do
            expect(instance.checksum).to match(/#{sha1sum_re}/)
            expect(instance.checksum).to eq(@plan_checksum)
          end
        end

        context 'when NO plan_output is present' do
          describe '#plan_output' do
            it 'returns the value of @plan_output' do
            expect(instance.plan_output).to eq(err_no_plan_output)
            end
          end

          describe '#to_markdown' do
            let(:markdown)    { instance.to_markdown }
            let(:markdown_re) { %r{#{err_no_plan_output}} }
            it 'emits plan formatted as markdown' do
              expect(markdown).to match(/#{markdown_re}/)
            end
          end
        end

        context 'when EXPLICIT plan_output is present' do
          describe '#plan_output=' do
            it 'accepts an arbitrary string as input' do
              instance.plan_output = plan_output
              expect(instance.plan_output).to be_truthy
            end
          end

          describe '#plan_output' do
            it 'returns the value of @plan_output' do
              instance.plan_output = plan_output
              expect(instance.plan_output).to eq(plan_output)
            end
          end

          describe '#to_markdown' do
            let(:markdown)    { instance.to_markdown }
            let(:markdown_re) { %r{#### #{@stack_dir}} }
            it 'emits plan formatted as markdown' do
              instance.plan_output = plan_output
              expect(markdown).to match(/#{markdown_re}/)
            end
          end
        end

        context 'when NO artifact_path is supplied' do
          describe '#save' do
            it 'serializes the PlanFile object to disk using default' do
              expect(instance.save).to be_truthy
              expect(File.exist?(instance.send(:artifact))).to be_truthy
            end
          end
          describe '#delete' do
            it 'removes the serialized PlanFile object from disk' do
              expect(instance.delete).to be_truthy
              expect(File.exist?(instance.send(:artifact))).to be_falsey
            end
          end
          describe '#exist?' do
            it 'reports artifact existence' do
              expect(instance.save).to be_truthy
              expect(instance.exist?).to be_truthy
              expect(instance.delete).to be_truthy
              expect(instance.exist?).to be_falsey
            end
          end
        end

        context 'when EXPLICIT artifact_path is supplied' do
          let(:artifact_path) do
            File.join(@stack_dir, 'explicit.planfile.data')
          end

          describe '#save' do
            it 'serializes the PlanFile object to disk using default' do
              expect(instance.save(artifact_path: artifact_path)).to be_truthy
              expect(File.exist?(artifact_path)).to be_truthy
            end
          end
          describe '#delete' do
            it 'removes the serialized PlanFile object from disk' do
              expect(instance.save(artifact_path: artifact_path)).to be_truthy
              expect(instance.delete).to be_truthy
              expect(File.exist?(artifact_path)).to be_falsey
            end
          end
          describe '#exist?' do
            it 'reports artifact existence' do
              expect(instance.save).to be_truthy
              expect(instance.exist?).to be_truthy
              expect(instance.delete).to be_truthy
              expect(instance.exist?).to be_falsey
            end
          end
        end
      end

      describe '.load' do
        let(:artifact_path) do
          instance.send(:artifact)
        end

        it 'loads a serialized PlanFile object from disk' do
          expect(instance.save).to be_truthy
          expect(described_class.load(artifact_path: artifact_path)).to be_a(described_class)
        end
      end
    end
  end

  context 'when binary is Terraform 0.12.x' do
    before(:all) do
      @stack_name    = 'stack_b'
      @stack_dir     = "stacks/#{@stack_name}"
      @plan_path     = "stacks/#{@stack_name}/#{@stack_name}.tfout"
      @artifacts     = terraform_cmd_artifacts(@stack_dir)
      @artifacts.each_pair { |_k,v| FileUtils.rm_rf(v) if File.exist?(v) }

      Terradactyl::Terraform::VersionManager.binaries.each do |file|
        FileUtils.rm_rf file
      end
      Terradactyl::Terraform::VersionManager.reset!

      @version       = '0.12.8'
      @plan_checksum = '19362d57c5403d040c4c304f5fe41e479aef20db'
      @options_init  = Commands::Options.new({quiet: true})
      @options_plan  = Commands::Options.new({
        quiet: true,
        detailed_exitcode: true,
        state: @artifacts.apply,
        out: @artifacts.plan
      })

      ENV['TF_PLUGIN_CACHE_DIR'] = File.expand_path('~/.terraform.d/plugins')

      VersionManager.install(@version)

      Commands::Init.execute(dir_or_plan: @stack_dir, options: @options_init)
      Commands::Plan.execute(dir_or_plan: @stack_dir, options: @options_plan)
    end

    after(:all) do
      @artifacts.each_pair { |_k,v| FileUtils.rm_rf(v) if File.exist?(v) }

      Terradactyl::Terraform::VersionManager.binaries.each do |file|
        FileUtils.rm_rf file
      end
      Terradactyl::Terraform::VersionManager.reset!
    end

    describe Terradactyl::Terraform::Rev012::PlanFileParser do
      context 'initialization' do
        describe '#load' do
          let(:instance) { described_class.load(@plan_path) }

          it 'loads and parses a terraform plan file' do
            expect(instance).to be_a(described_class)
            expect(instance).to respond_to(:checksum)
          end
        end
      end

      context 'initialized' do
        let(:instance) { described_class.load(@plan_path) }

        describe '#plan_path' do
          it 'shows the path to the plan' do
            expect(instance.plan_path).to eq(@plan_path)
          end
        end

        describe '#data' do
          it 'emits a parsable JSON string' do
            expect(instance.data).to be_a(String)
            expect(JSON.parse(instance.data)).to be_a(Hash)
          end
        end

        describe '#checksum' do
          let(:sha1sum_re) { /(?:[0-9a-f]){40}/ }
          it 'emits a checksum of the plan content' do
            expect(instance.checksum).to match(/#{sha1sum_re}/)
            expect(instance.checksum).to eq(@plan_checksum)
          end
        end
      end
    end

    describe Terradactyl::Terraform::PlanFile do
      let(:parser) { Terradactyl::Terraform::Rev012::PlanFileParser }
      let(:instance) do
        described_class.new(plan_path: @plan_path, parser: parser )
      end
      let(:delimiter)  { '-' * 72 }
      let(:rando_text) { 'some rando text' }
      let(:plan_output) do
        [
          delimiter,
          rando_text,
          delimiter,
        ].join($/)
      end
      let(:err_no_plan_output) { described_class::WARN_NO_PLAN_OUTPUT }

      context 'initialization' do
        context 'when plan_path is a non-existent file' do
          let(:parse_error) { Terradactyl::Terraform::PlanFileParserError }
          let(:instance) do
            described_class.new(plan_path: 'non-existent.tfout', parser: parser )
          end

          it 'rescues and captures a parse error' do
            expect(instance).to be_a(described_class)
            expect(instance.data).to be_a(parse_error)
          end
        end

        it 'loads and parses a terraform plan file' do
          expect(instance).to be_a(described_class)
          expect(instance).to respond_to(:checksum)
        end

        describe '#checksum' do
          let(:sha1sum_re) { /(?:[0-9a-f]){40}/ }
          it 'emits a checksum of the plan content' do
            expect(instance.checksum).to match(/#{sha1sum_re}/)
            expect(instance.checksum).to eq(@plan_checksum)
          end
        end

        context 'when NO plan_output is present' do
          describe '#plan_output' do
            it 'returns the value of @plan_output' do
            expect(instance.plan_output).to eq(err_no_plan_output)
            end
          end

          describe '#to_markdown' do
            let(:markdown)    { instance.to_markdown }
            let(:markdown_re) { %r{#{err_no_plan_output}} }
            it 'emits plan formatted as markdown' do
              expect(markdown).to match(/#{markdown_re}/)
            end
          end
        end

        context 'when EXPLICIT plan_output is present' do
          describe '#plan_output=' do
            it 'accepts an arbitrary string as input' do
              instance.plan_output = plan_output
              expect(instance.plan_output).to be_truthy
            end
          end

          describe '#plan_output' do
            it 'returns the value of @plan_output' do
              instance.plan_output = plan_output
              expect(instance.plan_output).to eq(rando_text)
            end
          end

          describe '#to_markdown' do
            let(:markdown)    { instance.to_markdown }
            let(:markdown_re) { %r{#### #{@stack_dir}} }
            it 'emits plan formatted as markdown' do
              instance.plan_output = plan_output
              expect(markdown).to match(/#{markdown_re}/)
            end
          end
        end

        context 'when NO artifact_path is supplied' do
          describe '#save' do
            it 'serializes the PlanFile object to disk using default' do
              expect(instance.save).to be_truthy
              expect(File.exist?(instance.send(:artifact))).to be_truthy
            end
          end
          describe '#delete' do
            it 'removes the serialized PlanFile object from disk' do
              expect(instance.delete).to be_truthy
              expect(File.exist?(instance.send(:artifact))).to be_falsey
            end
          end
          describe '#exist?' do
            it 'reports artifact existence' do
              expect(instance.save).to be_truthy
              expect(instance.exist?).to be_truthy
              expect(instance.delete).to be_truthy
              expect(instance.exist?).to be_falsey
            end
          end
        end

        context 'when EXPLICIT artifact_path is supplied' do
          let(:artifact_path) do
            File.join(@stack_dir, 'explicit.planfile.data')
          end

          describe '#save' do
            it 'serializes the PlanFile object to disk using default' do
              expect(instance.save(artifact_path: artifact_path)).to be_truthy
              expect(File.exist?(artifact_path)).to be_truthy
            end
          end
          describe '#delete' do
            it 'removes the serialized PlanFile object from disk' do
              expect(instance.save(artifact_path: artifact_path)).to be_truthy
              expect(instance.delete).to be_truthy
              expect(File.exist?(artifact_path)).to be_falsey
            end
          end
          describe '#exist?' do
            it 'reports artifact existence' do
              expect(instance.save).to be_truthy
              expect(instance.exist?).to be_truthy
              expect(instance.delete).to be_truthy
              expect(instance.exist?).to be_falsey
            end
          end
        end
      end

      describe '.load' do
        let(:artifact_path) do
          instance.send(:artifact)
        end

        it 'loads a serialized PlanFile object from disk' do
          expect(instance.save).to be_truthy
          expect(described_class.load(artifact_path: artifact_path)).to be_a(described_class)
        end
      end
    end
  end
end
