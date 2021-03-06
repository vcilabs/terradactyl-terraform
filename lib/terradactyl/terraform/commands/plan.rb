# frozen_string_literal: true

module Terradactyl
  module Terraform
    module Subcommands
      module Plan
        def defaults
          {
            'destroy' => false,
            'detailed-exitcode' => false,
            'input' => true,
            'lock' => true,
            'lock-timeout' => '0s',
            'module-depth' => -1,
            'no-color' => false,
            'out' => nil,
            'parallelism' => 10,
            'refresh' => true,
            'state' => 'terraform.tfstate',
            # 'target'            => [], # not implemented
            # 'var'               => [], # not implemented
            'var-file' => nil
          }
        end

        def switches
          %w[
            destroy
            detailed-exitcode
            no-color
          ]
        end
      end
    end

    module Commands
      class Plan < Base
      end
    end
  end
end
