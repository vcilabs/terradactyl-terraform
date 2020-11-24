# frozen_string_literal: true

module Terradactyl
  module Terraform
    module Rev011
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

    module Rev012
      module Refresh
        include Rev011::Refresh
      end
    end

    module Commands
      class Refresh < Base
      end
    end
  end
end
