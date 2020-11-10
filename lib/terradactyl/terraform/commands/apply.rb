# frozen_string_literal: true

module Terradactyl
  module Terraform
    module Rev011
      module Apply
        def defaults
          {
            'backup'       => nil,
            'auto-approve' => false,
            'lock'         => true,
            'lock-timeout' => '0s',
            'input'        => true,
            'no-color'     => false,
            'parallelism'  => 10,
            'refresh'      => true,
            'state'        => 'terraform.tfstate',
            'state-out'    => nil,
            # 'target'      => [], # not implemented
            # 'var'         => [], # not implemented
            'var-file'     => nil
          }
        end

        def switches
          %w[
            auto-approve
            no-color
          ]
        end
      end
    end

    module Rev012
      module Apply
        include Rev011::Apply
      end
    end

    module Rev013
      module Apply
        include Rev011::Apply
      end
    end

    module Commands
      class Apply < Base
      end
    end
  end
end
