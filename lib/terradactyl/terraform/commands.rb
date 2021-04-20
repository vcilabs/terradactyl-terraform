# frozen_string_literal: true

require_relative 'commands/options'
require_relative 'commands/base'
require_relative 'commands/version'
require_relative 'commands/init'
require_relative 'commands/plan'
require_relative 'commands/apply'
require_relative 'commands/refresh'
require_relative 'commands/destroy'
require_relative 'commands/fmt'
require_relative 'commands/show'
require_relative 'commands/validate'
require_relative 'commands/checklist'

module Terradactyl
  module Terraform
    Rev013 = Rev012.clone
    Rev014 = Rev013.clone
  end
end
