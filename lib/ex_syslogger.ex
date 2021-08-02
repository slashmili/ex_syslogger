defmodule ExSyslogger do
  @moduledoc """
  ExSyslogger is custom backend for Elixir Logger that logs to syslog by wrapping `erlang-syslog`.

  ## Features
  * Logs to syslog
  * Allows adding multiple backends with different configurations (e.g. each backend logs to a different facility with different log level)
  * Custom log formatter
  * Built-in JSON formatter(`poison` dependency is set to optional and you should explicitly add it to your dependency list)

  ## Installation

  Add `:ex_syslogger` as a dependency in your `mix.exs` file

  ### Elixir 1.5 and above

  ```elixir
  defp deps do
    [
      {:ex_syslogger, github: "slashmili/ex_syslogger", tag: "1.4.0"}
    ]
  end
  ```

  ### Elixir  ~> 1.4

  ```elixir
  defp deps do
    [
      {:ex_syslogger, "~> 1.3"}
    ]
  end
  ```

  Add `:ex_syslogger` to your list of `included_applications`:

  ```elixir
  def application do
    [included_applications: [:ex_syslogger]]
  end
  ```

  ## Configuration

  ExSyslogger is a Logger custom backend, as such, it relies on [Logger](http://elixir-lang.org/docs/stable/logger/) application.

  On your `config.exs` file tell `Logger` that it should add `ExSyslogger` backend
  ```
  config :logger,
    backends: [
              {ExSyslogger, :ex_syslogger_error},
              {ExSyslogger, :ex_syslogger_debug},
              {ExSyslogger, :ex_syslogger_json}
              ]
  ```

  With the configuration above, `Logger` application will add three `ExSyslogger` backend with the name `{ExSyslogger, :ex_syslogger_error}`, `{ExSyslogger, :ex_syslogger_debug}` and `{ExSyslogger, :ex_syslogger_json}`.

  You might notice that instead of just passing the Module name, we're passing a tuple with `{Module name, backend configuration name}`. This allow us to have multiple backends with different configuration. Let's configure the backends:

  ```
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
  ```


  ### Backend configuration properties

  * __level__ (optional): the logging level. It defaults to `:info`
  * __format__ (optional): Same as `:console` backend ([Logger.Formatter](http://elixir-lang.org/docs/stable/logger/)). It defaults to `"\n$date $time [$level] $levelpad$node $metadata $message\n"`
  * __formatter__ (optional): Formatter that will be used to format the log. It default to Logger.Formatter
  * __metadata__ (optional): Same as `:console` backend [Logger.Formatter](http://elixir-lang.org/docs/stable/logger/). It defaults to `[]`
  * __ident__ (optional): A string that's prepended to every message, and is typically set to the app name. It defaults to `"Elixir"`
  * __facility__ (optional): syslog facility to be used. It defaults to `:local0`. More documentation on [erlang-syslog](https://github.com/Vagabond/erlang-syslog/#syslogopenident-logopt-facility---ok-port)
  * __option__ (optional): syslog option to be used. It defaults to `:ndelay`. More documentation on [erlang-syslog](https://github.com/Vagabond/erlang-syslog/#syslogopenident-logopt-facility---ok-port)

  ## Custom Formatters
  ExSyslogger by default uses [Logger.Formatter](http://elixir-lang.org/docs/stable/logger/Logger.Formatter.html). However, it comes with a [JSON formatter](http://hexdocs.pm/exsyslog/1.0.1) that formats a given log entry to a JSON string. __NOTE__: `ExSyslogger.JsonFormatter` can be use as an example if one wants to build his own formatter.

  To build a custom formatter the formatter needs to implement the following functions:

  `compile(str)`
  Compiles a format string
  ```
  compile(binary | nil) :: [Logger.Formatter.pattern | binary]
  compile({atom, atom}) :: {atom, atom}
  ```

  `format(format, level, msg, timestamp, metadata, config_metadata)`
  Takes a compiled format and transforms it on a string that will be pass to syslog
  ```
  format({atom, atom} | [Logger.Formatter.pattern | binary], Logger.level, Logger.message, Logger.Formatter.time, Keyword.t, [atom]) :: IO.chardata
  ```

  To add the custom formatter you will need to set the `formatter` property on the configuration as exemplified above with `ExSyslogger.JsonFormatter`

  ## Try it

  In another shell:

  ```
  $ tail -f /var/log/syslog
  ```

  (Mac users)
  ```
  $ tail -f /var/log/system.log
  ```
  __NOTE__ Mac has a *funny* syslog. Your info logs might not show up. You'll need to configure your Mac syslog.

  Clone the project, go to examples/examples1 and run the project (`$ iex -S mix`).

  ```
  Erlang/OTP 18 [erts-7.0.2] [source] [64-bit] [smp:4:4] [async-threads:10] [hipe] [kernel-poll:false]

  Interactive Elixir (1.0.5) - press Ctrl+C to exit (type h() ENTER for help)
  iex(1)> Example1.run
  2015-09-11 15:26:18.850 [error] nonode@nohost module=Elixir.Example1 function=run/0 line=5  Hello ExSyslogger
  :ok
  ```

  You should see on the `tail -f` something similar to:

  `exsyslog_error` backend
  ```
  Sep 11 16:26:18 bt.local MyApplication[12833]: 2015-09-11 15:26:18.850 [error] nonode@nohost module=Elixir.Example1 function=run/0 line=5  Hello ExSyslogger
  ```

  `exsyslog_debug` backend
  ```
  Sep 11 16:26:18 bt.local MyApplication[12833]: 2015-09-11 15:26:18.850 [error] Hello ExSyslogger
  ```

  `exsyslog_json` backend
  ```
  Sep 11 16:26:18 bt.local MyApplication[12833]: {"node":"nonode@nohost","module":"Elixir.Example1","message":"Hello ExSyslogger","line":5,"level":"error","function":"run/0"}
  ```

  """

  @behaviour :gen_event

  @default_pattern "$date $time [$level] $levelpad$node $metadata $message\n"

  @doc false
  def init({__MODULE__, name}) do
    config = get_config(name, [])

    :syslog.start()
    {:ok, log} = open_log(config)

    {:ok, %{name: name, log: log, config: config}}
  end

  @doc """
  Changes backend configuration.
  """
  def handle_call(
        {:configure, options},
        %{name: name, log: log, config: config} = state
      ) do
    new_config = get_config(name, options)

    {:ok, log} =
      if config.facility !== new_config.facility or
           config.ident !== new_config.ident or
           config.option !== new_config.option or
           config.level !== new_config.level do
        close_log(log)
        open_log(new_config)
      else
        {:ok, log}
      end

    new_state = %{state | log: log, config: new_config}
    {:ok, :ok, new_state}
  end

  @doc """
  Handles a log event. Ignores the log event if the event level is less than the min log level.

  Ignores messages where the group leader is in a different node.
  """
  def handle_event({_level, gl, _event}, config) when node(gl) != node() do
    {:ok, config}
  end

  def handle_event(
        {level, _gl, {Logger, msg, timestamp, metadata}},
        %{log: log, config: config} = state
      ) do
    min_level = config.level

    if is_nil(min_level) or Logger.compare_levels(level, min_level) != :lt do
      priority = level_to_priority(level)
      event = format_event(level, msg, timestamp, metadata, config)
      :syslog.log(log, priority, event)
    end

    {:ok, state}
  end

  def handle_event(:flush, state), do: {:ok, state}

  ##############################################################################
  #
  # Internal functions

  defp level_to_priority(:debug), do: :debug
  defp level_to_priority(:info), do: :info
  defp level_to_priority(:warn), do: :warning
  defp level_to_priority(:error), do: :err

  defp get_config(name, options) do
    env = Application.get_env(:logger, name, [])
    configs = Keyword.merge(env, options)
    Application.put_env(:logger, :ex_syslogger, configs)

    level = Keyword.get(configs, :level, :info)
    metadata = Keyword.get(configs, :metadata, [])
    facility = Keyword.get(configs, :facility, :local0)
    option = Keyword.get(configs, :option, :ndelay)
    ident = Keyword.get(configs, :ident, "Elixir") |> String.to_charlist()

    formatter = Keyword.get(configs, :formatter, Logger.Formatter)
    format_str = Keyword.get(configs, :format, @default_pattern)
    format = apply(formatter, :compile, [format_str])

    %{
      format: format,
      formatter: formatter,
      level: level,
      metadata: metadata,
      ident: ident,
      facility: facility,
      option: option
    }
  end

  defp open_log(%{ident: ident, facility: facility, option: option}) do
    :syslog.open(ident, option, facility)
  end

  defp close_log(nil), do: :ok
  defp close_log(log) when is_port(log), do: :syslog.close(log)

  defp format_event(level, msg, timestamp, metadata, %{
         format: format,
         formatter: Logger.Formatter,
         metadata: config_metadata
       }) do
    metadata =
      if config_metadata == :all,
        do: metadata,
        else: Keyword.take(metadata, config_metadata)

    format
    |> Logger.Formatter.format(level, msg, timestamp, metadata)
    |> to_string()
  end

  defp format_event(level, msg, timestamp, metadata, %{
         format: format,
         formatter: formatter,
         metadata: config_metadata
       }) do
    apply(formatter, :format, [format, level, msg, timestamp, metadata, config_metadata])
  end

  @doc false
  def handle_info(_msg, state) do
    {:ok, state}
  end

  @doc false
  def terminate(_reason, _state) do
    :ok
  end

  @doc false
  def code_change(_old, state, _extra) do
    {:ok, state}
  end
end
