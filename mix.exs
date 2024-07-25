defmodule ExSyslogger.Mixfile do
  use Mix.Project

  @version "2.1.0"

  def project do
    [
      app: :ex_syslogger,
      version: @version,
      elixir: "~> 1.3",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      docs: [source_ref: "#{@version}", main: "ExSyslogger"],
      source_url: "https://github.com/slashmili/ex_syslogger"
    ]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:logger], included_applications: [:syslog]]
  end

  defp description do
    """
    ExSyslogger is an Elixir Logger custom backend to syslog.
    """
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README.md", "LICENSE"],
      maintainers: ["Milad Rastian"],
      licenses: ["MIT"],
      links: %{GitHub: "https://github.com/slashmili/ex_syslogger"}
    ]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [
      {:syslog, "~> 1.1.0"},
      {:ex_doc, "~> 0.25.1", only: :dev, runtime: false},
      {:jason, "~> 1.2", optional: true}
    ]
  end
end
