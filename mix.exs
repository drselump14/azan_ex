defmodule Azan.MixProject do
  @moduledoc """
    mix for azan_ex
  """
  use Mix.Project

  def project do
    [
      app: :azan_ex,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      preferred_cli_env: [
        "test.watch": :test
      ],
      deps: deps()
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(:dev), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:astro, "~> 0.9.2"},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:ex_doc, "~> 0.27", only: :dev, runtime: false},
      {:ex_guard, path: "../../ex_guard", only: :dev},
      {:ex_machina, "~> 2.7.0"},
      {:ex_unit_notifier, "~> 1.2", only: :test},
      {:faker, "~> 0.17", only: :test},
      {:math, "~> 0.7.0"},
      {:mix_test_watch, "~> 1.0", only: [:dev, :test], runtime: false},
      {:oban, "~> 2.12.0"},
      {:timex, "~> 3.7"},
      {:typed_struct, "~> 0.3.0"}
    ]
  end
end
