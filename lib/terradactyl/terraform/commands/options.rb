# frozen_string_literal: true

module Terradactyl
  module Terraform
    module Commands
      class Options < OpenStruct
        def initialize(hash = {})
          super(defaults.merge(hash))
          yield(self) if block_given?
        end

        def defaults
          {
            echo: false,
            quiet: false,
            environment: {}
          }
        end
      end
    end
  end
end
