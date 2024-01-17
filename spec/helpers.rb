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
        rev1_02: {
          version: '1.2.0',
          plan_checksum: '53f1cf9d6ddf2357a860c8bcf6ef53e53c97bd50',
          artifacts: {
            init:    '.terraform',
            lock:    '.terraform.lock.hcl',
            plan:    'rev1_02.tfout',
            apply:   'terraform.tfstate',
            refresh: 'terraform.tfstate',
            destroy: 'terraform.tfstate',
            lint:    'unlinted.tf',
          }
        },
        rev1_03: {
          version: '1.3.0',
          plan_checksum: '4b4efff7f4c5cee21951342a43d981885d568a06',
          artifacts: {
            init:    '.terraform',
            lock:    '.terraform.lock.hcl',
            plan:    'rev1_03.tfout',
            apply:   'terraform.tfstate',
            refresh: 'terraform.tfstate',
            destroy: 'terraform.tfstate',
            lint:    'unlinted.tf',
          }
        },
        rev1_04: {
          version: '1.4.0',
          plan_checksum: '7e58409d316b6ec636084177a625b652d92910db',
          artifacts: {
            init:    '.terraform',
            lock:    '.terraform.lock.hcl',
            plan:    'rev1_04.tfout',
            apply:   'terraform.tfstate',
            refresh: 'terraform.tfstate',
            destroy: 'terraform.tfstate',
            lint:    'unlinted.tf',
          }
        },
        rev1_05: {
          version: '1.5.0',
          plan_checksum: '2b808a969767c5ac8ea37c893d4769afdc52e8f7',
          artifacts: {
            init:    '.terraform',
            lock:    '.terraform.lock.hcl',
            plan:    'rev1_05.tfout',
            apply:   'terraform.tfstate',
            refresh: 'terraform.tfstate',
            destroy: 'terraform.tfstate',
            lint:    'unlinted.tf',
          }
        },
        rev1_06: {
          version: '1.6.0',
          plan_checksum: '1369a4d666a2e73402313ba117b0a6d3ae1f82b9',
          artifacts: {
            init:    '.terraform',
            lock:    '.terraform.lock.hcl',
            plan:    'rev1_06.tfout',
            apply:   'terraform.tfstate',
            refresh: 'terraform.tfstate',
            destroy: 'terraform.tfstate',
            lint:    'unlinted.tf',
          }
        },
        rev1_07: {
          version: '1.7.0',
          plan_checksum: 'd85d9bd8233484cbacc0d4136d72d18c87df5a96',
          artifacts: {
            init:    '.terraform',
            lock:    '.terraform.lock.hcl',
            plan:    'rev1_07.tfout',
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
