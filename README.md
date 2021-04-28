# Terradactyl::Terraform

[![Gem Version](https://badge.fury.io/rb/terradactyl-terraform.svg)](https://badge.fury.io/rb/terradactyl-terraform)
![Build Status](https://github.com/vcilabs/terradactyl-terraform/workflows/Build%20Status/badge.svg)

Library for executing Terraform CLI operations, managing Terraform binary versions, and other related tasks.

## Requirements

Requires Ruby 2.5 or greater.

NOTE: While `VersionManager` can fetch & install ANY available version of Terraform, the Terraform sub-command operations are only supported between stable versions `~> 0.11.x` and `~> 0.15.x`.

## Installation

### Bundler

Add this line to your application's Gemfile ...

```ruby
gem 'terradactyl-terraform'
```

And then execute:

    $ bundle install

### Manual

    $ gem install terradactyl-terraform

## Usage

If you wish to try out some features, launch a `pry` repl and poke around ...

    $ bundle exec pry -r 'terradactyl/terraform'
    [1] pry(main)> Terradactyl::Terraform::VERSION
    => "0.15.0"

### Managing  different Terraform versions

The `VersionManager` module can manage different versions of Terraform based on explicit versions or Gem-like expressions:

##### install the latest version of 0.12.x (pessimistic spec)
    [1] pry(main)> latest_012x = '~> 0.12.0'
    "~> 0.12.0"
    [2] pry(main)> Terradactyl::Terraform::VersionManager.install(latest_012x)
    => "/Users/vcilabs/bin/terraform-0.12.29"

##### find the latest stable version for Terraform and insall it
    [1] pry(main)> to_install = Terradactyl::Terraform::VersionManager.latest
    => "0.13.5"
    [2] pry(main)> Terradactyl::Terraform::VersionManager.install(to_install)
    => "/Users/vcilabs/bin/terraform-0.13.5"

##### install a legacy version
    [3] pry(main)> Terradactyl::Terraform::VersionManager.install('0.11.14')
    => "/Users/vcilabs/bin/terraform-0.11.14"

##### get a list of insalled Terraforms
    [3] pry(main)> Terradactyl::Terraform::VersionManager.versions
    => ["0.11.14", "0.12.29", "0.13.5"]
    [3] pry(main)> Terradactyl::Terraform::VersionManager.binaries
    => ["/Users/vcilabs/bin/terraform-0.11.14",
     "/Users/vcilabs/bin/terraform-0.12.29",
     "/Users/vcilabs/bin/terraform-0.13.5"]

##### get a list of available Terraforms
    [3] pry(main)> Terradactyl::Terraform::VersionManager.versions(local: false)
    => ["0.1.0",
     "0.1.1",
     "0.2.0",
     "0.2.1",
     "0.2.2",
     "0.3.0",
     "0.3.1",
     "0.3.5",
     ...]

### Working with Terraform stacks

    Dir.chdir 'spec/fixtures'
    include Terradactyl::Terraform

    ENV['TF_PLUGIN_CACHE_DIR'] = File.expand_path('~/.terraform.d/plugins')

    stack_name = 'stack_a'
    stack_dir  = "stacks/#{stack_name}"
    state_file = "stacks/#{stack_name}/terraform.tfstate"
    plan_file  = "stacks/#{stack_name}/#{stack_name}.tfout"
    options    = Terradactyl::Terraform::Commands::Options

    plan_options = options.new({
                    quiet: false,
                    detailed_exitcode: true,
                    state: state_file,
                    out: plan_file
                  })

    VersionManager.version = '~> 0.12.1'
    VersionManager.install

    Commands::Version.execute(dir_or_plan: stack_dir)
    Commands::Fmt.execute(dir_or_plan: stack_dir)
    Commands::Init.execute(dir_or_plan: stack_dir)
    Commands::Validate.execute(dir_or_plan: stack_dir)
    Commands::Plan.execute(dir_or_plan: stack_dir, options: plan_options)
    Commands::Show.execute(dir_or_plan: plan_file)
    Commands::Apply.execute(dir_or_plan: plan_file)
    Commands::Destroy.execute(dir_or_plan: stack_dir, options: options.new({auto_approve: true}))

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/vcilabs/terradactyl-terraform
