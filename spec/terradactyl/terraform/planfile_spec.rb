require 'spec_helper'

include Terradactyl::Terraform

RSpec.describe Terradactyl::Terraform::PlanFile do

  before(:all) do
    @version    = '0.11.14'
    @stack_name = 'stack_b'
    @stack_dir  = "stacks/#{@stack_name}"
    @plan_path  = "stacks/#{@stack_name}/#{@stack_name}.tfout"
    @artifacts  = terraform_cmd_artifacts(@stack_dir)
    @artifacts.each_pair { |_k,v| FileUtils.rm_rf(v) if File.exist?(v) }

    @options_init = Commands::Options.new({quiet: true})
    @options_plan = Commands::Options.new({
      quiet: true,
      detailed_exitcode: true,
      state: @artifacts.apply,
      out: @artifacts.plan
    })

    ENV['TF_PLUGIN_CACHE_DIR'] = File.expand_path('~/.terraform.d/plugins')
    VersionManager.install(@version)
  end


  before(:each) do
    Commands::Init.execute(dir_or_plan: @stack_dir, options: @options_init)
    Commands::Plan.execute(dir_or_plan: @stack_dir, options: @options_plan)
  end

  after(:each) do
    @artifacts.each_pair { |_k,v| FileUtils.rm_rf(v) if File.exist?(v) }
  end

  context 'initialization' do
    describe '#load' do
      it 'loads and parses a terraform plan file' do
        expect(described_class.load(@plan_path)).to be_a(described_class)
        expect(described_class.load(@plan_path)).to respond_to(:checksum)
      end
    end
  end

  context 'initialized' do

    let(:instance) { described_class.load(@plan_path) }

    describe '#checksum' do
      let(:sha1sum_re) { /(?:[0-9a-f]){40}/ }
      it 'emits a checksum of the plan content' do
        expect(instance.checksum).to match(/#{sha1sum_re}/)
      end
    end

    describe '#to_markdown' do
      let(:markdown)    { instance.to_markdown }
      let(:markdown_re) { %r{#### #{@stack_name}} }
      it 'emits plan formatted as markdown' do
        expect(markdown).to match(/#{markdown_re}/)
      end
    end
  end

end
