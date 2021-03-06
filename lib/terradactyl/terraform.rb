# frozen_string_literal: true

require 'zip'
require 'English'
require 'open3'
require 'open-uri'
require 'yaml'
require 'json'
require 'ostruct'
require 'deepsort'
require 'deep_merge'
require 'digest'
require 'forwardable'

require_relative 'terraform/version'
require_relative 'terraform/planfile'
require_relative 'terraform/commands'
require_relative 'terraform/version_manager'
