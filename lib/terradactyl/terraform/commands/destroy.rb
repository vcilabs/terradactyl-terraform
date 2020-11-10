# frozen_string_literal: true

module Terradactyl
  module Terraform
    module Rev011
      module Destroy
        def defaults
          {
            'backup'       => nil,
            'auto-approve' => false,
            'force'        => false,
            'lock'         => true,
            'lock-timeout' => '0s',
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
            force
            no-color
          ]
        end
      end
    end

    module Rev012
      module Destroy
        include Rev011::Destroy
      end
    end

    module Rev013
      module Destroy
        include Rev011::Destroy
      end
    end

    module Commands
      class Destroy < Base
      end
    end
  end
end
