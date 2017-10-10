## [1.4.0] - 2017-08-02

## Add
- Support of Elixir 1.5
- Throw error if Json format is used but poison is not added as dependency

## Changed
- Replace GenEvent with `:gen_event` since it's deprecated in Elixir 1.5
- Update `erlang-syslog` to 1.0.5

## [1.3.4] - 2017-08-02
### Add
- Add travis test
- Drop support for Elixir  <= 1.2

## Changed
- Fix example project

## [1.3.3] - 2017-01-24
### Changed
- wider the range of poison that works with this repo
