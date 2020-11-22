# frozen_string_literal: true

module Terradactyl
  module Terraform
    module Rev011
      module Fmt
        def defaults
          {
            'list' => true,
            'write' => true,
            'diff' => false,
            'check' => false
          }
        end

        def switches
          []
        end
      end
    end

    module Rev012
      module Fmt
        include Rev011::Fmt
      end
    end

    module Commands
      class Fmt < Base
      end
    end
  end
end
