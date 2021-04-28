# frozen_string_literal: true

module Terradactyl
  module Terraform
    module Subcommands
      module Validate
        def defaults
          {
            'check-variables' => true,
            'no-color' => false,
            # 'var'             => [], # not implemented
            'var-file' => nil
          }
        end

        def switches
          %w[
            no-color
          ]
        end
      end
    end

    module Rev012
      module Validate
        def defaults
          {
            'no-color' => nil,
            'json' => nil
          }
        end

        def switches
          %w[
            no-color
            json
          ]
        end
      end
    end

    module Commands
      class Validate < Base
      end
    end
  end
end
