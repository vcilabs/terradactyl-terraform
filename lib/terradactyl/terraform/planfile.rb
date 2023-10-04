# frozen_string_literal: true

module Terradactyl
  module Terraform
    class PlanFileParserError < RuntimeError; end

    module Rev012
      class PlanFileParser
        attr_reader :plan_path

        PLAN_FILE_SIGNATURE = 'Terraform will perform the following actions'

        def self.load(plan_path)
          new(plan_path)
        end

        def initialize(plan_path)
          @plan_path = plan_path
        end

        def checksum
          Digest::SHA1.hexdigest(data)
        end

        def data
          @data ||= parse(@plan_path)
        end

        def signature
          self.class::PLAN_FILE_SIGNATURE
        end

        private

        # rubocop:disable Metrics/AbcSize
        def parse(plan_path)
          file_name  = File.basename(plan_path)
          stack_name = File.dirname(plan_path)
          pushd(stack_name)

          captured = Commands::Show.execute(dir_or_plan: file_name,
                                            options: options,
                                            capture: true)

          unless captured.exitstatus.zero?
            raise PlanFileParserError, 'Error parsing plan file!'
          end

          return captured.stdout unless options.json

          parsed = JSON.parse(captured.stdout)

          # The the  `prior_state` node in the JSON returned from the
          # planfile is not assembled consistently and therefore, never obeys
          # any sort order. It does not appear to be of any consequence when
          # calculating a checksum for the plan, so we excise it in an effort
          # to conform the data. This is sub-optimal, but presently necessary.
          #
          # brian.warsing@visioncritical.com (2020-06-18)

          # The same must be done to the `timestamp` node introduced in TF 1.5
          #
          # lisa.li@alida.com (2023-06-12)

          parsed.reject { |k| k == 'prior_state' }.to_json
          parsed.reject { |k| k == 'timestamp' }.to_json
        ensure
          popd
        end
        # rubocop:enable Metrics/AbcSize

        def options
          Commands::Options.new do |opts|
            opts.environment = {}
            opts.no_color    = true unless ENV['TF_CLI_ARGS'] =~ /-no-color/
            opts.json        = true
          end
        end

        def pushd(path)
          @working_dir_last = Dir.pwd
          Dir.chdir(path)
        end

        def popd
          Dir.chdir(@working_dir_last)
        end
      end
    end

    module Rev013
      class PlanFileParser < Rev012::PlanFileParser
      end
    end

    module Rev014
      class PlanFileParser < Rev012::PlanFileParser
      end
    end

    module Rev015
      class PlanFileParser < Rev012::PlanFileParser
      end
    end

    module Rev1_00
      class PlanFileParser < Rev012::PlanFileParser
      end
    end

    module Rev1_01
      class PlanFileParser < Rev012::PlanFileParser
      end
    end

    module Rev1_02
      class PlanFileParser < Rev012::PlanFileParser
      end
    end

    module Rev1_03
      class PlanFileParser < Rev012::PlanFileParser
      end
    end

    module Rev1_04
      class PlanFileParser < Rev012::PlanFileParser
      end
    end

    module Rev1_05
      class PlanFileParser < Rev012::PlanFileParser
      end
    end

    module Rev1_06
      class PlanFileParser < Rev012::PlanFileParser
      end
    end

    module Rev011
      class PlanFileParser < Rev012::PlanFileParser
        def checksum
          Digest::SHA1.hexdigest(normalize(data))
        end

        private

        def options
          Commands::Options.new do |opts|
            opts.environment = {}
            opts.no_color    = true unless ENV['TF_CLI_ARGS'] =~ /-no-color/
          end
        end

        def normalize(data)
          lines = data.split("\n").each_with_object([]) do |line, memo|
            memo << normalize_line(line)
          end
          lines.join("\n")
        end

        def re_json_blob
          /\"{\\n.+?\\n}\"/
        end

        def re_json_line
          /^(?<attrib>\s+\w+:\s+)(?<json>.+?#{re_json_blob}.*)/
        end

        def normalize_json(blob)
          if blob.match(re_json_blob)
            # rubocop:disable Security/Eval
            un_esc = eval(blob).chomp
            return JSON.parse(un_esc).deep_sort.to_json.inspect
          end
          blob
        end
        # rubocop:enable Security/Eval

        def normalize_line(line)
          if (caps = line.match(re_json_line))
            blobs = caps['json'].split(' => ').map { |blob| normalize_json(blob) }
            blobs = blobs.join(' => ')
            line  = [caps['attrib'], blobs.to_s].join
          end
          line
        rescue JSON::ParserError
          line
        end
      end
    end

    class PlanFile
      def self.load(artifact_path: artifact)
        # rubocop:disable Security/MarshalLoad
        Marshal.load(File.read(artifact_path))
      end
      # rubocop:enable Security/MarshalLoad

      attr_reader   :data, :checksum, :file_name, :stack_name, :parser
      attr_writer   :plan_output, :error_output
      attr_accessor :base_folder

      WARN_NO_PLAN_OUTPUT = 'WARN: no plan output is available'

      def initialize(plan_path:, parser:)
        @plan_path   = plan_path.to_s
        @file_name   = File.basename(@plan_path)
        @stack_name  = File.basename(@plan_path, '.tfout')
        @base_folder = File.dirname(@plan_path).split('/')[-2]
        @parser      = parse(parser, @plan_path)
      end

      def save(artifact_path: artifact)
        @artifact = artifact_path
        File.write(artifact, Marshal.dump(self))
      end

      def delete
        FileUtils.rm(artifact) if exist?
      end

      def exist?
        File.exist?(artifact)
      end

      def plan_output
        format_plan_output(@plan_output)
      end

      def error_output
        format_error_output(@error_output)
      end

      def to_markdown
        [
          "#### #{[base_folder, stack_name].compact.join('/')}",
          '```',
          plan_output,
          '```'
        ].compact.join("\n")
      end

      def to_s
        data
      end

      def <=>(other)
        data <=> other.data
      end

      private

      def parse(parser, plan_path)
        parser.load(plan_path).tap do |dat|
          @data     = dat.data
          @checksum = dat.checksum
        end
      rescue PlanFileParserError => e
        @data = e
      end

      def artifact
        @artifact ||= File.join(ENV['TF_DATA_DIR'],
                                'terradactyl.planfile.data')
      end

      def format_error_output(string)
        string.strip
      end

      def format_plan_output(string)
        return WARN_NO_PLAN_OUTPUT unless string

        # These hypens are different!
        delimit = /(?:─|-){72,77}/
        content = string.split(delimit).compact.reject(&:empty?)

        content.select { |e| e =~ /#{parser.signature}/ }.first.strip
      end
    end
  end
end
