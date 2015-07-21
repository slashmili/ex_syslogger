ExSyslog
======

ExSyslog is custom backend for `Elixir Logger` that logs to syslog by wrapping [erlang-syslog](https://github.com/Vagabond/erlang-syslog/).

## Requirements
* Elixir ~> 1.0

## Features
* Logs to syslog
* Allows adding multiple backends with different configurations (e.g. each backend logs to a different facility with different log level)

## Installation

Add `:exsyslog` and `:syslog` as a dependency in your `mix.exs` file

```elixir

defp deps do
  [
    {:exsyslog, "~> 0.0.1"},
    {:syslog, github: "Vagabond/erlang-syslog", tag: "1.0.3"}
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
            ]
```

With the configuration above, `logger` application will add two `ExSyslog` backend with the name `{ExSyslog, :exsyslog_error}` and `{ExSyslog, :exsyslog_debug}`.

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
```


### Backend configuration properties

* __level__ (optional): the logging level. It defaults to `:info`
* __format__ (optional): Same as `:console` backend ([Logger.Formatter](http://elixir-lang.org/docs/stable/logger/)). It defaults to `"\n$date $time [$level] $levelpad$node $metadata $message\n"`
* __metadata__ (optional): Same as `:console` backend [Logger.Formatter](http://elixir-lang.org/docs/stable/logger/). It defaults to `[]`
* __ident__ (optional): A string that's prepended to every message, and is typically set to the app name. It defaults to `"Elixir"`
* __facility__ (optional): syslog facility to be used. It defaults to `:local0`. More documentation on [erlang-syslog](https://github.com/Vagabond/erlang-syslog/#syslogopenident-logopt-facility---ok-port)
* __option__ (optional): syslog option to be used. It defaults to `:ndelay`. More documentation on [erlang-syslog](https://github.com/Vagabond/erlang-syslog/#syslogopenident-logopt-facility---ok-port)


## Authors

* Bruno Tavares (<btavares@22cans.com>)

## License

exsyslog is copyright (c) 2015 22cans Ltd.

The source code is released under the MIT License.

Check [LICENSE](LICENSE) for more information.
