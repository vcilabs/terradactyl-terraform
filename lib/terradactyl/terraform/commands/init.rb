# frozen_string_literal: true

module Terradactyl
  module Terraform
    module Subcommands
      module Init
        def defaults
          {
            'backend' => true,
            'backend-config' => nil,
            'from-module' => nil,
            'get' => true,
            'get-plugins' => true,
            'input' => true,
            'lock' => true,
            'lock-timeout' => '0s',
            'plugin-dir' => nil,
            'upgrade' => false,
            'verify-plugins' => true,
            'no-color' => false,
            'force-copy' => false,
            'reconfigure' => false
          }
        end

        def switches
          %w[
            no-color
            force-copy
            reconfigure
          ]
        end
      end
    end

    module Rev015
      module Init
        include Terradactyl::Terraform::Subcommands::Init

        def defaults
          super.reject { |k, _v| k == 'lock' }
        end

        def arguments
          super.reject { |k, _v| k == 'lock' }
        end
      end
    end

    module Commands
      class Init < Base
      end
    end
  end
end
