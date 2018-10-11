defmodule Fuzz.MixProject do
  use Mix.Project

  def project do
    [
      app: :fuzz,
      version: "0.1.0",
      elixir: "~> 1.6",
      escript: escript(),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def escript do
    [main_module: Fuzz]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :mix, :inets],
      mod: {Fuzz.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
      {:propcheck, "~> 1.1"}
    ]
  end
end