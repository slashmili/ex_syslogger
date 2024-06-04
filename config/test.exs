import Config

config :logger,
  utc_log: true,
  truncate: 8192,
  sync_threshold: 40,
  discard_threshold_for_error_logger: 500,
  compile_time_purge_matching: [[level_lower_than: :debug]],
  backends: [
            {ExSyslogger, :ex_syslogger_error},
            {ExSyslogger, :ex_syslogger_debug},
            {ExSyslogger, :ex_syslogger_json}
            ]

config :logger, :console,
  level: :error,
  format: "$date $time [$level] $node $metadata $message\n",
  metadata: [:module, :line, :function]

config :logger, :ex_syslogger_error,
  level: :error,
  format: "$date $time [$level] $node $metadata $message",
  metadata: [:module, :line, :function],
  ident: "MyApplication Error",
  facility: :local0,
  option: [:pid, :cons]

config :logger, :ex_syslogger_debug,
  level: :debug,
  format: "$date $time [$level] $message",
  ident: "MyApplication DEBUG",
  facility: :local1,
  option: [:pid, :perror]

config :logger, :ex_syslogger_json,
  level: :debug,
  format: "$message",
  formatter: ExSyslogger.JsonFormatter,
  metadata: [:module, :line, :function],
  ident: "MyApplication JSON",
  facility: :local1,
  option: :pid
