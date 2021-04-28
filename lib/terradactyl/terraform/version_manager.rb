# frozen_string_literal: true

require_relative 'version_manager/inventory'
require_relative 'version_manager/defaults'
require_relative 'version_manager/downloader'
require_relative 'version_manager/package'
require_relative 'version_manager/binary'

module Terradactyl
  module Terraform
    # rubocop:disable Metrics/ModuleLength
    module VersionManager
      class VersionManagerError < RuntimeError
        def initialize(msg)
          super(msg)
        end
      end

      ERROR_MISSING                = 'Terraform not installed'
      ERROR_INVALID_VERSION_STRING = 'Invalid version string'
      ERROR_UNRESOLVABLE_VERSION   = 'Unresolvable version string'
      ERROR_UNPARSEABLE_VERSION    = 'Unparsable version string'
      SEMVER_EXP_RE                = /
        ^\s*((?<op>(=|<=|>=|>|<|~>))\s+)?
        (?<semver>\d+(\.\d+)?(\.\d+)?(-\w+)?)
      /x.freeze

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

          raise VersionManagerError, ERROR_MISSING
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

          remote_versions
        rescue StandardError
          warn "Failed to retrieve releases [#{releases_url}]"
          warn "Falling back to local inventory [#{install_dir}]"
          inventory.versions
        end

        def resolve(expression)
          unless (resolution = resolve_expression(expression.to_s.strip))
            raise VersionManagerError, ERROR_UNRESOLVABLE_VERSION
          end

          resolution
        end

        private

        def resolve_expression(expression)
          candiates = case expression
                      when /^~>/
                        resolve_pessimistic(expression)
                      when /^(?:>=|>|<=|<)/
                        resolve_range(expression)
                      when /^(?:=\s+)?\d+\.\d+\.\d+(?:-.*)?/
                        return resolve_equality(expression)
                      else
                        raise VersionManagerError, ERROR_INVALID_VERSION_STRING
                      end

          candiates.reject { |v| v =~ /-/ }.last
        end

        def resolve_equality(expression)
          expression.split(/\s+/).last
        end

        # rubocop:disable Metrics/AbcSize
        def resolve_range(expression)
          left, right    = expression.split(/\s*,\s*/)
          l_op, l_semver = parse_expression(left).captures

          if right
            r_op, r_semver = parse_expression(right).captures
          else
            r_op = l_op
            r_semver = l_semver
          end

          l_gemver = Gem::Version.new(l_semver)
          r_gemver = Gem::Version.new(r_semver)

          versions(local: false).select do |v|
            v = Gem::Version.new(v)
            (v.send(l_op.to_sym, l_gemver) && v.send(r_op.to_sym, r_gemver))
          end
        end
        # rubocop:enable Metrics/AbcSize

        def resolve_pessimistic(expression)
          semver    = parse_expression(expression).captures.last
          min       = Gem::Version.new(semver)
          max       = Gem::Version.new(pessimistic_max(semver))

          versions(local: false).select do |v|
            v = Gem::Version.new(v)
            (v >= min && v < max)
          end
        end

        def parse_expression(expression)
          match = expression.to_s.match(SEMVER_EXP_RE)
          raise VersionManagerError, ERROR_UNPARSEABLE_VERSION unless match

          match
        end

        def remote_versions
          fh = Downloader.fetch(releases_url)
          re = /terraform_(?<version>\d+\.\d+\.\d+(-\w+)?)/
          fh.read.scan(re).flatten.sort_by { |v| Gem::Version.new(v) }
        end

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
    # rubocop:enable Metrics/ModuleLength
  end
end
