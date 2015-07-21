defmodule ExSyslog do
  @moduledoc false
  use GenEvent

  @default_pattern "\n$date $time [$level] $levelpad$node $metadata $message\n"

  def init({__MODULE__, name}) do
    config = get_config(name, [])

    :syslog.start()
    {:ok, log} = open_log(config)

    {:ok, %{name: name, log: log, config: config}}
  end

  @doc """
  Changes backend configuration.
  """
  def handle_call({:configure, options},
                  %{name: name, log: log, config: config} = state) do
    new_config = get_config(name, options)

    if config.facility !== new_config.facility or
       config.ident !== new_config.ident or
       config.option !== new_config.option do

        close_log(log)
        {:ok, log} = open_log(new_config)
    end

    new_state = %{state | log: log, config: new_config}
    {:ok, :ok, new_state}
  end

  @doc """
  Ignore messages where the group leader is in a different node.
  """
  def handle_event({_level, gl, _event}, config) when node(gl) != node() do
    {:ok, config}
  end

  @doc """
  Handles an log event. Ignores the log event if the event level is less than the min log level.
  """
  def handle_event({level, _gl, {Logger, msg, ts, md}},
                   %{log: log, config: config} = state) do
    min_level = config.level

    if is_nil(min_level) or Logger.compare_levels(level, min_level) != :lt do
      priority = level_to_priority(level)
      event = format_event(level, msg, ts, md, config)
      :syslog.log(log, priority, event)
    end

    {:ok, state}
  end


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
    Application.put_env(:logger, :exsyslog, configs)

    format = Keyword.get(configs, :format, @default_pattern)
             |> Logger.Formatter.compile()
    level = Keyword.get(configs, :level, :info)
    metadata = Keyword.get(configs, :metadata, [])
    facility = Keyword.get(configs, :facility, :local0)
    option = Keyword.get(configs, :option, :ndelay)
    json? = Keyword.get(configs, :wrap_to_json, false)
    ident = Keyword.get(configs, :ident, "Elixir") |> String.to_char_list()

    %{format: format,
      level: level,
      metadata: metadata,
      ident: ident,
      facility: facility,
      option: option,
      json?: json?}
  end

  defp open_log(%{ident: ident, facility: facility, option: option}) do
    :syslog.open(ident, option, facility)
  end

  defp close_log(nil), do: :ok
  defp close_log(log) when is_port(log), do: :syslog.close(log)

 defp format_event(level, msg, ts, md, config) do
    metadata = md |> Keyword.take(config.metadata)

    config.format
    |> Logger.Formatter.format(level, msg, ts, metadata)
    |> to_string()
 end

end
