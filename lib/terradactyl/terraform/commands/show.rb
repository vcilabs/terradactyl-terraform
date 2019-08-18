# frozen_string_literal: true

module Terradactyl
  module Terraform
    module Rev011
      module Show
        def defaults
          {
            'module-depth' => -1,
            'no-color'     => false
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
      module Show
        include Rev011::Show
      end
    end

    module Commands
      class Show < Base
      end
    end
  end
end
