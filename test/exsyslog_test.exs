defmodule ExsyslogTest do
  use ExUnit.Case

  require Logger
  test "different level of logs" do
    debug_log = "debug log #{random_str()}"
    Logger.debug debug_log

    info_log = "info log #{random_str()}"
    Logger.info info_log

    error_log = "error log #{random_str()}"
    Logger.error error_log
  end

  def random_str do
    18
    |> :crypto.strong_rand_bytes
    |> Base.encode16
  end
end
