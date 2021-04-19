module Helpers
  class << self
    def terraform_test_matrix
      {
        rev011: {
          version: '0.11.14',
          plan_checksum: '3c85565fdddeb6e16d900cc70d824d2e5b291da6',
          artifacts: {
            init:    '.terraform',
            plan:    'rev011.tfout',
            apply:   'terraform.tfstate',
            refresh: 'terraform.tfstate.backup',
            destroy: 'terraform.tfstate.backup',
            lint:    'unlinted.tf',
          }
        },
        rev012: {
          version: '0.12.30',
          plan_checksum: '15b03b347551cc56b1cf0f69c61329d957790bf6',
          artifacts: {
            init:    '.terraform',
            plan:    "rev012.tfout",
            apply:   'terraform.tfstate',
            refresh: 'terraform.tfstate.backup',
            destroy: 'terraform.tfstate.backup',
            lint:    'unlinted.tf',
          }
        },
        rev013: {
          version: '0.13.6',
          plan_checksum: 'f5df851473542cac1d40dd045f92901bb59c827a',
          artifacts: {
            init:    '.terraform',
            plan:    "rev013.tfout",
            apply:   'terraform.tfstate',
            refresh: 'terraform.tfstate',
            destroy: 'terraform.tfstate',
            lint:    'unlinted.tf',
          }
        },
        # rev014: {
        #   version: '0.14.10',
        #   artifacts: {
        #     init:    '.terraform',
        #     lock:    '.terraform.lock.hcl',
        #     plan:    "rev014.tfout",
        #     apply:   'terraform.tfstate',
        #     refresh: 'terraform.tfstate',
        #     destroy: 'terraform.tfstate',
        #     lint:    'unlinted.tf',
        #   }
        # },
      }
    end
  end

  @@original_stderr = $stderr
  @@original_stdout = $stdout

  def disable_output
    $stderr = File.open(File::NULL, 'w')
    $stdout = File.open(File::NULL, 'w')
  end

  def enable_output
    $stderr = @@original_stderr
    $stdout = @@original_stdout
  end

  def silence(&block)
    disable_output
    yield
  ensure
    enable_output
  end

  def terraform_minimum
    '0.11.10'
  end

  def terraform_legacy
    '0.11.14'
  end

  def terraform_latest
    calculate_latest
  end

  def calculate_latest
    fh = Downloader.fetch(downloads_url)
    re = %r{#{releases_url}\/(?<version>\d+\.\d+\.\d+)}
    fh.read.match(re)['version']
  ensure
    fh.close
    fh.unlink
  end

  def downloads_url
    'https://www.terraform.io/downloads.html'
  end

  def releases_url
    'https://releases.hashicorp.com/terraform'
  end
end
