# frozen_string_literal: true

module Terradactyl
  module Terraform
    module VersionManager
      class Defaults
        DEFAULT_INSTALL_DIR   = Gem.bindir
        DEFAULT_DOWNLOADS_URL = 'https://www.terraform.io/downloads.html'
        DEFAULT_RELEASES_URL  = 'https://releases.hashicorp.com/terraform'
        DEFAULT_BINARY        = 'terraform'

        def self.load
          new
        end

        attr_reader :install_dir, :downloads_url, :releases_url

        def initialize
          load_defaults
        end

        def reset!
          load_defaults
        end

        def binary
          VersionManager.list.last || DEFAULT_BINARY
        end

        def binary=(option)
          @binary = validate_path(option) || binary
        end

        def install_dir=(option)
          @install_dir = validate_path(option) || DEFAULT_INSTALL_DIR
        end

        def downloads_url=(option)
          @downloads_url = validate_url(option) || DEFAULT_DOWNLOADS_URL
        end

        def releases_url=(option)
          @releases_url = validate_url(option) || DEFAULT_RELEASES_URL
        end

        private

        def validate_path(option)
          return nil if option.to_s.empty?

          dir = File.expand_path(option)
          Dir.exist?(dir) ? dir : nil
        end

        def validate_url(option)
          return nil if option.to_s.empty?

          uri = URI.parse(option)
          url if uri.kind_of?(URI::HTTP) || uri.kind_of?(URI::HTTPS)
        end

        def load_defaults
          @install_dir   = DEFAULT_INSTALL_DIR
          @downloads_url = DEFAULT_DOWNLOADS_URL
          @releases_url  = DEFAULT_RELEASES_URL
          @binary        = DEFAULT_BINARY
        end
      end
    end
  end
end
