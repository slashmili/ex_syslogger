## [2.0.0] - 2021-08-02

### Changed
- Breaking change: Replace Poison with Jason


## [1.5.2] - 2020-04-30

### Fixed
- syslog dependency was not able to compile with new rebar


## [1.5.1] - 2020-04-15

### Fixed
- Accept :all as metadate in Logger config


## [1.5.0] - 2018-12-17

### Changed
- Removed poison from applications list

## [1.4.1] - 2018-08-29

### Changed
- Support :all for config metadata

## [1.4.1] - 2018-08-27

### Changed
- Update formatter to support ref, pid and mfa 

## [1.4.0] - 2017-08-02

### Add
- Support of Elixir 1.5
- Throw error if Json format is used but poison is not added as dependency

### Changed
- Replace GenEvent with `:gen_event` since it's deprecated in Elixir 1.5
- Update `erlang-syslog` to 1.0.5

### Removed
- Drop support for Elixir <= 1.2

## [1.3.4] - 2017-08-02
### Add
- Add travis test

## Changed
- Fix example project

## [1.3.3] - 2017-01-24
### Changed
- wider the range of poison that works with this repo
