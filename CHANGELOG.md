# CHANGELOG

## 1.0.0 (2021-06-09)

NEW FEATURES:

* add support for Terraform version `~> 1.0.0`

BUG FIXES:

* fix broken version revision resolution

## 0.15.0 (2021-04-27)

NEW FEATURES:

* adds support for Terraform version `0.14.x`
* adds support for Terraform version `0.15.x`

BUG FIXES:

* fix broken version expression resolution

## 0.13.0 (2020-11-23)

NEW FEATURES:

* adds support for Terraform version 0.13.x
* adds expressive Terraform version management (i.e. pessimistic operator, ~> 0.12.1)
* update Gem version string to match supported Terraform revision

BUG FIXES:

* fix/refactor/re-rog tests and update README

## 0.4.2 (2020-06-18)

BUG FIXES:

* fix `Rev012::PlanFileParser`
   - excise irrelevant data to ensure consistent checksum
* fix tests
  - specify and updated `null_resource` provider
  - update static checksum values

## 0.4.1 (2019-09-17)

BUG FIXES:

* fix unhandled exception when a proper plan file cannot be produced

## 0.4.0 (2019-09-13)

BUG FIXES:

* specify Rev012::Show command options
* create terraform revision-specific parser classes
* overhaul PlanFile class
  - accept revision-specific parser class as parameter
  - add `#plan_output` method to stash and retrieve plan's stdout
  - add `#save`, `#delete`, `#exist?` methods to manage as serialized
    object on disk
  - add `.load` to load from serialized object from disk

## 0.3.1 (2019-09-06)

BUG FIXES:

* fix Terraform revision module injection
  - add Base#version; derived from binary
* fix Rev012::Validate
  - add `defaults` and `switches`
* break subcommand specs into separate revisions
* refactor tests

## 0.3.0 (2019-08-24)

NEW FEATURES:

* remove `autoinstall` feature
  - conflation of concerns; this behaviour belongs to the Gem's consumers
* update VersionManager::Defaults
  - drop default value for `binary`
  - remove default `version` value; now `nil`
* add VersionManager::Inventory
  - capture version query logic in a separate class

BUG FIXES:

* refactor VersionManager
  - drop support for un-managed Terraform binaries
  - dynamic lookups on managed binaries only
  - drop seatbelt and min. version; unused
  - refactor tests
* cleanup some Rubocop violations

## 0.2.0 (2019-08-04)

NEW FEATURES:

* implement class versioning scheme for Terraform sub-commands
  - handles CLI arg/switch changes between different Terraform revisions

BUG FIXES:

* correct defaults on `-no-color` CLI switches
* rename VersionManager::Options to VersionManager::Defaults
  - add method `#binary`; performs lookup, prefers latest and falls back to
  `$PATH/terraform`
* factor out VersionManager#search; replaced by VersionManager#binary
  - same functionality, but kicked up to VersionManager::Defaults#binary
  - replace `binary` default for Commands::Options#defaults
* fix bad default on Commands::Base#subcmd

## 0.1.1 (2019-07-31)

NEW FEATURES:

    * implement `terraform validate`:
      - add Commands::Validate and spec
    * implement `terraform 0.12checklist`:
      - add Commands::Checklist and spec
