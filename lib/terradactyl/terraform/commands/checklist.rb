# frozen_string_literal: true

module Terradactyl
  module Terraform
    module Commands
      class Checklist < Base
        def defaults
          {}
        end

        def switches
          []
        end

        def subcmd
          '0.12checklist'
        end
      end
    end
  end
end
