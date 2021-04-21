# frozen_string_literal: true

module Terradactyl
  module Terraform
    module Subcommands
      module Refresh
        def defaults
          {
            'backup' => nil,
            'input' => true,
            'lock' => true,
            'lock-timeout' => '0s',
            'no-color' => false,
            'state' => 'terraform.tfstate',
            'state-out' => nil,
            # 'target'      => [], # not implemented
            # 'var'         => [], # not implemented
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

    module Commands
      class Refresh < Base
      end
    end
  end
end
