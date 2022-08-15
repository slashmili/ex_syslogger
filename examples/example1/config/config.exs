# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for third-
# party users, it should be done in your mix.exs file.

# Sample configuration:
#
#     config :logger, :console,
#       level: :info,
#       format: "$date $time [$level] $metadata$message\n",
#       metadata: [:user_id]

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
#     import_config "#{Mix.env}.exs"

config :logger,
  utc_log: true,
  truncate: 8192,
  sync_threshold: 40,
  discard_threshold_for_error_logger: 500,
  compile_time_purge_matching: [[level_lower_than: :debug]],
  backends: [
            :console,
            {ExSyslogger, :ex_syslogger_error},
            {ExSyslogger, :ex_syslogger_debug},
            {ExSyslogger, :ex_syslogger_json}
            ]

config :logger, :console,
  level: :error,
  format: "$date $time [$level] $levelpad$node $metadata $message\n",
  metadata: [:module, :line, :function]

config :logger, :ex_syslogger_error,
  level: :error,
  format: "$date $time [$level] $levelpad$node $metadata $message",
  metadata: [:module, :line, :function],
  ident: "MyApplication",
  facility: :local0,
  option: [:pid, :cons]

config :logger, :ex_syslogger_debug,
  level: :debug,
  format: "$date $time [$level] $message",
  ident: "MyApplication",
  facility: :local1,
  option: [:pid, :perror]

config :logger, :ex_syslogger_json,
  level: :debug,
  format: "$message",
  formatter: ExSyslogger.JsonFormatter,
  metadata: [:module, :line, :function],
  ident: "MyApplication",
  facility: :local1,
  option: :pid
