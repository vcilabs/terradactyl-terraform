# frozen_string_literal: true

module Terradactyl
  module Terraform
    module Rev011
      module Init
        def defaults
          {
            'backend'        => true,
            'backend-config' => nil,
            'from-module'    => nil,
            'get'            => true,
            'get-plugins'    => true,
            'input'          => true,
            'lock'           => true,
            'lock-timeout'   => '0s',
            'plugin-dir'     => nil,
            'upgrade'        => false,
            'verify-plugins' => true,
            'no-color'       => false,
            'force-copy'     => false,
            'reconfigure'    => false
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

    module Rev012
      module Init
        include Rev011::Init
      end
    end

    module Rev013
      module Init
        include Rev011::Init
      end
    end

    module Commands
      class Init < Base
      end
    end
  end
end
