ExSyslog
======

ExSyslog is custom backend for `Elixir Logger` that logs to syslog by wrapping [erlang-syslog](https://github.com/Vagabond/erlang-syslog/).

## Requirements
* Elixir ~> 1.0

## Features
* Logs to syslog
* Allows adding multiple backends with different configurations (e.g. each backend logs to a different facility with different log level)
* Custom log formatter
* Built-in JSON formatter

## Installation

Add `:exsyslog` and `:syslog` as a dependency in your `mix.exs` file

```elixir

defp deps do
  [
    {:exsyslog, "~> 0.1.0"}
  ]
end
```

## Configuration

ExSyslog is a Logger custom backend, as such, it relies on [:logger](http://elixir-lang.org/docs/stable/logger/) application.

On your `config.exs` file tell `Logger` that it should add `ExSyslog` backend
```
config :logger,
  backends: [
            {ExSyslog, :exsyslog_error},
            {ExSyslog, :exsyslog_debug}
            {ExSyslog, :exsyslog_json}
            ]
```

With the configuration above, `logger` application will add three `ExSyslog` backend with the name `{ExSyslog, :exsyslog_error}`, `{ExSyslog, :exsyslog_debug}` and `{ExSyslog, :exsyslog_json}`.

You might notice that instead of just passing the Module name, we're passing a tuple with `{Module name, backend configuration name}`. This allow us to have multiple backends with different configuration. Let's configure the backends:

```
config :logger, :exsyslog_error,
  level: :error,
  format: "$date $time [$level] $levelpad$node $metadata $message",
  metadata: [:module, :line, :function],
  ident: "MyApplication",
  facility: :local0,
  option: [:pid, :cons]

config :logger, :exsyslog_debug,
  level: :debug,
  format: "$date $time [$level] $message",
  ident: "MyApplication",
  facility: :local1,
  option: [:pid, :perror]

config :logger, :exsyslog_json,
  level: :debug,
  format: "$message",
  formatter: ExSyslog.JsonFormatter,
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
ExSyslog by default uses [Logger.Formatter](http://elixir-lang.org/docs/stable/logger/Logger.Formatter.html). However, it comes with a [JSON formatter](http://hexdocs.pm/exsyslog/0.1.0) that formats a given log entry to a JSON string. __NOTE__: `ExSyslog.JsonFormatter` can be use as an example if one wants to build his own formatter.

To build a custom formatter the formatter needs to implement the following functions:

`compile(str)` Compiles a format string
```
compile(binary | nil) :: [Logger.Formatter.pattern | binary]
compile({atom, atom}) :: {atom, atom}
```

`format(format, level, msg, timestamp, metadata, config_metadata)` Takes a compiled format and transforms it on a string that will be pass to syslog
```
format({atom, atom} | [Logger.Formatter.pattern | binary], Logger.level, Logger.message, Logger.Formatter.time, Keyword.t, [atom]) :: IO.chardata
```

To add the custom formatter you will need to set the `formatter` property on the configuration as exemplified above with `ExSyslog.JsonFormatter`

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

```
Erlang/OTP 18 [erts-7.0.1] [source] [64-bit] [smp:4:4] [async-threads:10] [hipe] [kernel-poll:false] [dtrace]

Interactive Elixir (1.0.5) - press Ctrl+C to exit (type h() ENTER for help)
iex(1)> require Logger
nil
iex(2)> Logger.error "Hello syslog"
:ok
```

## Authors

* Bruno Tavares (<btavares@22cans.com>)

## License

exsyslog is copyright (c) 2015 22cans Ltd.

The source code is released under the MIT License.

Check [LICENSE](LICENSE) for more information.
