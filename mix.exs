defmodule Assign2.MixProject do
  use Mix.Project

  def project do
    [
      app: :assign2,
      version: "0.1.0",
      elixir: "~> 1.9",
      escript: escript(),
      start_permanent: Mix.env() == :prod,
      build_embedded: Mix.env == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
    ]
  end

  defp escript do
    [main_module: Assign2.EscriptFile]
  end
  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
