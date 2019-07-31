# frozen_string_literal: true

module Terradactyl
  module Terraform
    module Commands
      class Validate < Base
        def defaults
          {
            'check-variables' => true,
            'no-color'        => true,
            # 'var'             => [], # not implemented
            'var-file'        => nil,
          }
        end

        def switches
          %w[
            no-color
          ]
        end
      end
    end
  end
end
