defmodule ExSyslogger.JsonFormatter do
  @moduledoc """
  JsonFormatter is formatter that produces a properly JSON object string where the level, message, node, and metadata are JSON object root properties.

  JSON object:
  ```
    {
      "level": "error",
      "message": "hello JSON formatter",
      "node": "foo@local",
      "module": "MyApp.MyModule",
      "function": "do_something/2",
      "line": 21
    }
  ```

  JSON string:
  ```
  {\"level\":\"error\",\"message\":\"hello JSON formatter\",\"node\":\"foo@local\",\"module\":\"MyApp.MyModule\",\"function\":\"do_something\/2\",\"line\":21}

  ```
  """

  @doc """
  Compiles a format string into an array that the `format/6` can handle.
  It uses Logger.Formatter.
  """
  @spec compile({atom, atom}) :: {atom, atom}
  @spec compile(binary | nil) :: [Logger.Formatter.pattern | binary]

  defdelegate compile(str), to: Logger.Formatter

  @doc """
  Takes a compiled format and injects the level, message, node and metadata and returns a properly formatted JSON object where level, message, node and metadata properties are root JSON properties. Message is formated with Logger.Formatter.

  `config_metadata`: is the metadata that is set on the configuration e.g. "metadata: [:module, :line, :function]".
  """
  @spec format({atom, atom} | [Logger.Formatter.pattern | binary],
               Logger.level, Logger.message, Logger.Formatter.time,
               Keyword.t, list(atom)) :: IO.chardata

  def format(format, level, msg, timestamp, metadata, config_metadata) do
    case Code.ensure_loaded(Poison) do
      {:error, _} -> throw :add_poison_to_your_deps
      _ -> nil
    end
    metadata = metadata |> Keyword.take(config_metadata)

    msg_str = format
              |> Logger.Formatter.format(level, msg, timestamp, metadata)
              |> to_string()

    log = %{level: level, message: msg_str, node: node()}

    metadata = Enum.reduce(metadata, log, &add_to_log/2)
    {:ok, log_json} = apply(Poison, :encode, [metadata])

    log_json
  end


  ##############################################################################
  #
  # Internal functions

  defp add_to_log({_, nil}, log), do: log
  defp add_to_log({key, value}, log), do: Map.put(log, key, value)

end
