defmodule ExSyslog.JsonFormatter do
  @moduledoc """
  JsonFormatter is formatter that produces a properly JSON object string where the level, message and metadata are JSON object root properties.

  JSON object:
  ```
    {
      "level": "error",
      "message": "hello JSON formatter",
      "module": "MyApp.MyModule",
      "function": "do_something/2",
      "line": 21
    }
  ```

  JSON string:
  ```
  {\"level\":\"error\",\"message\":\"hello JSON formatter\",\"module\":\"MyApp.MyModule\",\"function\":\"do_something\/2\",\"line\":21}

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
  Takes a compiled format and injects the level, message and metadata and returns a properly formatted JSON object where level, message and metadata properties are root JSON properties. Message is formated with Logger.Formatter.
  """
  @spec format({atom, atom} | [Logger.Formatter.pattern | binary],
               Logger.level, Logger.message, Logger.Formatter.time,
               Keyword.t, list(atom)) :: IO.chardata

  def format(format, level, msg, timestamp, metadata, config_metadata) do
    metadata = metadata |> Keyword.take(config_metadata)

    msg_str = format
              |> Logger.Formatter.format(level, msg, timestamp, metadata)
              |> to_string()

    log = %{level: level, message: msg_str}

    {:ok, log_json} = metadata
                      |> Enum.reduce(log, &add_to_log/2)
                      |> Poison.encode()

    log_json
  end


  ##############################################################################
  #
  # Internal functions

  defp add_to_log({_, nil}, log), do: log
  defp add_to_log({key, value}, log), do: Dict.put(log, key, value)

end
