# frozen_string_literal: true

module Terradactyl
  module Terraform
    module VersionManager
      class InventoryError < RuntimeError
        def initialize(msg, version)
          @version = version
          err_fmt  = "#{msg} -- version: %s"
          super(err_fmt % @version)
        end
      end

      class Inventory
        ERROR_VERSION_MISSING = 'Version not installed'

        include Enumerable

        def self.load
          new
        end

        def install_dir
          VersionManager.install_dir
        end

        def binaries
          Dir.glob("#{install_dir}/terraform-*").sort
        end

        def versions
          (binaries.map do |path|
            File.basename(path).match(inventory_name_re)['version']
          end).sort
        end

        def manifest
          Hash[versions.zip(binaries)]
        end

        def latest
          versions.last
        end

        def validate(semver)
          return manifest[semver] if manifest[semver]

          raise error_version_missing(semver)
        end

        def [](semver)
          manifest[semver]
        end

        def each(&block)
          manifest.each(&block)
        end

        private

        def error_version_missing(version)
          raise InventoryError.new(ERROR_VERSION_MISSING, version)
        end

        def inventory_name_re
          /(?:terraform-)(?<version>\d+\.\d+\.\d+(-\w+)?)/
        end
      end
    end
  end
end
