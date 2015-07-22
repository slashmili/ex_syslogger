use Mix.Config

config :logger,
  utc_log: true,
  truncate: 8192,
  sync_threshold: 40,
  discard_threshold_for_error_logger: 500,
  compile_time_purge_level: :debug

config :logger, :console,
  level: :error,
  format: "$date $time [$level] $levelpad$node $metadata $message\n",
  metadata: [:module, :line, :function]

config :logger, :exsyslog_error,
  level: :error,
  format: "$date $time [$level] $levelpad$node $metadata $message\n",
  formatter: Logger.Formatter,
  metadata: [:module, :line, :function],
  ident: "SyslogError",
  facility: :local0,
  option: [:pid, :cons]

config :logger, :exsyslog_info,
  level: :info,
  format: "$message",
  formatter: ExSyslog.JsonFormatter,
  metadata: [:module, :line, :function],
  ident: "SyslogInfo",
  facility: :local0,
  option: [:pid, :cons]
