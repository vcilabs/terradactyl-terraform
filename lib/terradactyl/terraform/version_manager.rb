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

      ERROR_MISSING                = 'Terraform not installed'
      ERROR_INVALID_VERSION_STRING = 'Invalid version string'
      SEMVER_EXP_RE                = %r{
        ^\s*((?<op>(<=|>=|>|<|~>))\s+)?
        (?<semver>\d+(\.\d+)?(\.\d+)?(-\w+)?)
      }x

      @options   = Defaults.load
      @inventory = Inventory.load

      class << self
        extend Forwardable

        def_delegators :@options, :version, :version=, :install_dir,
                       :install_dir=, :downloads_url, :downloads_url=,
                       :releases_url, :releases_url=, :reset!

        def_delegators :@inventory, :[], :binaries, :any?

        attr_reader :inventory

        def options
          block_given? ? yield(@options) : @options
        end

        def binary
          return inventory.validate(current_version) if version
          return inventory[inventory.latest] if inventory.any?

          raise VersionManagerError.new(ERROR_MISSING)
        end

        def latest
          calculate_latest
        end

        def install(semver = nil, type: Binary)
          semver ||= version
          package = type.new(version: resolve(semver))
          package.install
        end

        def remove(semver = nil, type: Binary)
          semver ||= version
          package = type.new(version: resolve(semver))
          package.remove
        end

        def current_version
          resolve(version)
        end

        def versions(local: true)
          return inventory.versions if local
          fh = Downloader.fetch(releases_url)
          re = %r{terraform_(?<version>\d+\.\d+\.\d+(-\w+)?)}
          fh.read.scan(re).flatten.sort_by { |v| Gem::Version.new(v) }
        rescue
          warn "Failed to retrieve releases [#{releases_url}]"
          warn "Falling back to local inventory [#{install_dir}]"
          inventory.versions
        ensure
          if fh
            fh.close
            fh.unlink
          end
        end

        def resolve(expression)
          data   = expression.to_s.match(SEMVER_EXP_RE) || {}
          op     = data['op']
          semver = data['semver']

          resolution = case op
          when /~>/
            min = semver
            max = pessimistic_max(semver)
            versions(local: false).select { |v| (v >= min && v < max) }.last
          when />=|>|<=|</
            versions(local: false).select { |v| (v.send(op.to_sym, semver)) }.last
          else
            versions(local: false).delete(semver)
          end

          return resolution if resolution

          raise VersionManagerError.new(ERROR_INVALID_VERSION_STRING)
        end

        private

        def pessimistic_max(version)
          max = version.split(/\.|-/).map(&:to_i)
          max.pop if max.size > 1
          max[-1] += 1
          max.join('.')
        end

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
