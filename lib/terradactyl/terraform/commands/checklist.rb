# frozen_string_literal: true

module Terradactyl
  module Terraform
    module Rev011
      module Checklist
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

    module Rev012
      module Checklist
        include Rev011::Checklist
      end
    end

    module Rev013
      module Checklist
        include Rev011::Checklist
      end
    end

    module Commands
      class Checklist < Base
      end
    end
  end
end
