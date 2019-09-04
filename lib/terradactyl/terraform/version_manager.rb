# frozen_string_literal: true

require_relative 'version_manager/inventory'
require_relative 'version_manager/defaults'
require_relative 'version_manager/downloader'
require_relative 'version_manager/package'
require_relative 'version_manager/binary'

module Terradactyl
  module Terraform
    module VersionManager
      class VersionManagerError < RuntimeError
        def initialize(msg)
          super(msg)
        end
      end

      ERROR_MISSING = 'Terraform not installed'

      @options   = Defaults.load
      @inventory = Inventory.load

      class << self
        extend Forwardable

        def_delegators :@options, :version, :version=, :install_dir,
                       :install_dir=, :downloads_url, :downloads_url=,
                       :releases_url, :releases_url=, :reset!

        def_delegators :@inventory, :[], :versions, :binaries, :any?

        attr_reader :inventory

        def options
          block_given? ? yield(@options) : @options
        end

        def binary
          return inventory.validate(version) if version
          return inventory[inventory.latest] if inventory.any?

          raise VersionManagerError.new(ERROR_MISSING)
        end

        def latest
          calculate_latest
        end

        def install(semver = nil, type: Binary)
          semver ||= version
          package = type.new(version: semver)
          package.install
        end

        def remove(semver = nil, type: Binary)
          semver ||= version
          package = type.new(version: semver)
          package.remove
        end

        private

        def calculate_latest
          fh = Downloader.fetch(downloads_url)
          re = %r{#{releases_url}\/(?<version>\d+\.\d+\.\d+)}
          fh.read.match(re)['version']
        ensure
          fh.close
          fh.unlink
        end
      end
    end
  end
end
