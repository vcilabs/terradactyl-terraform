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
            plan:    'rev012.tfout',
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
            plan:    'rev013.tfout',
            apply:   'terraform.tfstate',
            refresh: 'terraform.tfstate',
            destroy: 'terraform.tfstate',
            lint:    'unlinted.tf',
          }
        },
        rev014: {
          version: '0.14.10',
          plan_checksum: '1faac8f9f7119dface5a695b45815956ac30babf',
          artifacts: {
            init:    '.terraform',
            lock:    '.terraform.lock.hcl',
            plan:    'rev014.tfout',
            apply:   'terraform.tfstate',
            refresh: 'terraform.tfstate',
            destroy: 'terraform.tfstate',
            lint:    'unlinted.tf',
          }
        },
        rev015: {
          version: '0.15.0',
          plan_checksum: 'b9dc844a69ab5551177485b3bf09debc2f074ddf',
          artifacts: {
            init:    '.terraform',
            lock:    '.terraform.lock.hcl',
            plan:    'rev015.tfout',
            apply:   'terraform.tfstate',
            refresh: 'terraform.tfstate',
            destroy: 'terraform.tfstate',
            lint:    'unlinted.tf',
          }
        },
        rev1_00: {
          version: '1.0.11',
          plan_checksum: '4f706dc6e0b9a7c5a4ecc31f34d879f18f49f28f',
          artifacts: {
            init:    '.terraform',
            lock:    '.terraform.lock.hcl',
            plan:    'rev1_00.tfout',
            apply:   'terraform.tfstate',
            refresh: 'terraform.tfstate',
            destroy: 'terraform.tfstate',
            lint:    'unlinted.tf',
          }
        },
        rev1_01: {
          version: '1.1.2',
          plan_checksum: '3d2c2f48370010196e402894d90b516af5953fd0',
          artifacts: {
            init:    '.terraform',
            lock:    '.terraform.lock.hcl',
            plan:    'rev1_01.tfout',
            apply:   'terraform.tfstate',
            refresh: 'terraform.tfstate',
            destroy: 'terraform.tfstate',
            lint:    'unlinted.tf',
          }
        },
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
    Terradactyl::Terraform::VersionManager.latest
  end

  def resolve_version(exp)
    Terradactyl::Terraform::VersionManager.resolve(exp)
  end
end
