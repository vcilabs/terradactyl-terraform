# frozen_string_literal: true

module Terradactyl
  module Terraform
    module Subcommands
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

    module Commands
      class Fmt < Base
      end
    end
  end
end
