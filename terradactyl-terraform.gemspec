lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'terradactyl/terraform/version'

Gem::Specification.new do |spec|
  spec.name          = 'terradactyl-terraform'
  spec.version       = Terradactyl::Terraform::VERSION
  spec.authors       = ['Brian Warsing']
  spec.email         = ['brian.warsing@visioncritical.com']
  spec.summary       = %{Core functionality for managing a Terraform repo}
  spec.homepage      = %{https://git.vcilabs.com/CloudEng/terradactyl-terraform}
  spec.description   = <<~DESC
    A collection of libraries for executing Terraform CLI operations, managing
    Terraform binary versions, and other related tasks.
  DESC

  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'http://gems.media.service.consul:8808'
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  spec.required_ruby_version = '>= 2.5.0'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'rubyzip', '>= 1.0.0'
  spec.add_dependency 'deepsort', '~> 0.4'
  spec.add_dependency 'deep_merge', '~> 1.2'
  spec.add_dependency 'bundler', '>= 1.16'
  spec.add_dependency 'rake', '>= 10.0'

  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rspec-command', '~> 1.0'
  spec.add_development_dependency 'pry', '~> 0.12'
  spec.add_development_dependency 'rubocop', '~> 0.71.0'
end
