# frozen_string_literal: true

module Terradactyl
  module Terraform
    module Subcommands
      module Destroy
        def defaults
          {
            'backup' => nil,
            'auto-approve' => false,
            'force' => false,
            'lock' => true,
            'lock-timeout' => '0s',
            'no-color' => false,
            'parallelism' => 10,
            'refresh' => true,
            'state' => 'terraform.tfstate',
            'state-out' => nil,
            # 'target'      => [], # not implemented
            # 'var'         => [], # not implemented
            'var-file' => nil
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

    module Rev015
      module Destroy
        include Terradactyl::Terraform::Subcommands::Destroy

        def defaults
          super.reject { |k, _v| k == 'force' }
        end

        def switches
          super.reject { |e| e == 'force' }
        end

        def arguments
          super.reject { |k, _v| k == 'force' }
        end
      end
    end

    module Rev1_00
      module Destroy
        include Terradactyl::Terraform::Rev015::Destroy
      end
    end

    module Rev1_01
      module Destroy
        include Terradactyl::Terraform::Rev015::Destroy
      end
    end

    module Rev1_02
      module Destroy
        include Terradactyl::Terraform::Rev015::Destroy
      end
    end

    module Rev1_03
      module Destroy
        include Terradactyl::Terraform::Rev015::Destroy
      end
    end

    module Rev1_04
      module Destroy
        include Terradactyl::Terraform::Rev015::Destroy
      end
    end

    module Rev1_05
      module Destroy
        include Terradactyl::Terraform::Rev015::Destroy
      end
    end

    module Commands
      class Destroy < Base
      end
    end
  end
end
