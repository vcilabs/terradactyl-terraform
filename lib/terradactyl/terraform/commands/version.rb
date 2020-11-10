# frozen_string_literal: true

module Terradactyl
  module Terraform
    module Rev011
      module Version
      end
    end

    module Rev012
      module Version
        include Rev011::Version
      end
    end

    module Rev013
      module Version
        include Rev011::Version
      end
    end

    module Commands
      class Version < Base
      end
    end
  end
end
