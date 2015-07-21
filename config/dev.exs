use Mix.Config

config :logger,
  utc_log: true,
  truncate: 8192,
  sync_threshold: 40,
  # handle_otp_reports: true,
  # handle_sasl_reports: true,
  discard_threshold_for_error_logger: 500,
  compile_time_purge_level: :debug

config :logger, :console,
  level: :error,
  format: "$date $time [$level] $levelpad$node $metadata $message\n",
  # utc_log: true,
  # truncate: 8192,
  # sync_threshold: 40,
  metadata: [:module, :line, :function]
  # handle_otp_reports: true,
  # handle_sasl_reports: true,
  # discard_threshold_for_error_logger: 500,
  # compile_time_purge_level: :debug

# config :sasl,
#   errlog_type: :error,
#   utc_log: true

config :logger, :TestSyslogError,
  level: :error,
  format: "\n$date $time [$level] $levelpad$node $metadata $message\n",
  metadata: [:module, :line, :function],
  ident: "TestSyslogError",
  facility: :local0,
  option: [:pid, :cons],
  wrap_to_json: true

config :logger, :TestSyslogInfo,
  level: :info,
  format: "\n$date $time [$level] $levelpad$node $metadata $message\n",
  metadata: [:module, :line, :function],
  ident: "TestSyslogInfo",
  facility: :local0,
  option: [:pid, :cons],
  wrap_to_json: true

