# frozen_string_literal: true

module Terradactyl
  module Terraform
    class PlanFileParserError < RuntimeError; end

    module Rev012
      class PlanFileParser
        attr_reader :plan_path

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

        private

        def parse(plan_path)
          captured = Commands::Show.execute(dir_or_plan: plan_path,
                                            options: options,
                                            capture: true)

          unless captured.exitstatus.zero?
            raise PlanFileParserError.new('Error parsing plan file!')
          end

          return captured.stdout unless options.json

          parsed = JSON.parse(captured.stdout)

          # The the  `prior_state` node in the JSON returned from the
          # planfile is not assembled consitently and therefore, never obeys
          # any sort order. It does not appear to be of any consequence when
          # calculating a checksum for the plan, so we excise it in an effort
          # to conform the data. This is sub-optimal, but presently necessary.
          #
          # brian.warsing@visioncritical.com (2020-06-18)

          parsed.reject { |k| k == 'prior_state' }.to_json
        end

        def options
          Commands::Options.new do |opts|
            opts.environment = {}
            opts.no_color    = true unless ENV['TF_CLI_ARGS'] =~ /-no-color/
            opts.json        = true
          end
        end
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
            un_esc = eval(blob).chomp
            return JSON.parse(un_esc).deep_sort.to_json.inspect
          end
          blob
        end

        def normalize_line(line)
          if (caps = line.match(re_json_line))
            blobs = caps['json'].split(' => ').map { |blob| normalize_json(blob) }
            blobs = blobs.join(' => ')
            line  = [caps['attrib'], %(#{blobs})].join
          end
          line
        rescue JSON::ParserError
          line
        end
      end
    end

    module Rev013
      class PlanFileParser < Rev012::PlanFileParser
      end
    end

    class PlanFile
      def self.load(artifact_path: artifact)
        Marshal.load(File.read(artifact_path))
      end

      attr_reader   :data, :checksum, :file_name, :stack_name
      attr_accessor :base_folder, :plan_output

      WARN_NO_PLAN_OUTPUT = 'WARN: no plan output is available'

      def initialize(plan_path:, parser:)
        @plan_path   = plan_path.to_s
        @parser      = parser
        @file_name   = File.basename(@plan_path)
        @stack_name  = File.basename(@plan_path, '.tfout')
        @base_folder = File.dirname(@plan_path).split('/')[-2]

        parse(@plan_path)
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
        format_output(@plan_output)
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

      def parse(plan_path)
        @parser.load(plan_path).tap do |dat|
          @data     = dat.data
          @checksum = dat.checksum
        end
      rescue PlanFileParserError => error
        @data = error
      end

      def artifact
        @artifact ||= File.join(ENV['TF_DATA_DIR'],
                                'terradactyl.planfile.data')
      end

      def format_output(string)
        return WARN_NO_PLAN_OUTPUT unless string

        delimit = '-' * 72
        content = string.split(delimit).compact.reject(&:empty?)

        if content.size == 2
          content.last.strip
        else
          content[content.size / 3].strip
        end
      end
    end
  end
end
