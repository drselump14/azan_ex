defmodule Azan.Azan.MixProject do
  @moduledoc """
    mix for azan_ex
  """
  use Mix.Project

  def project do
    [
      app: :azan_ex,
      version: "0.3.0",
      elixir: "~> 1.13",
      compilers: [:domo_compiler] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.github": :test,
        "test.watch": :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      deps: deps(),
      package: package(),
      name: "AzanEx",
      description: description(),
      source_url: "https://github.com/drselump14/azan_ex"
    ]
  end

  defp description do
    "Calculating Azan times for a given location"
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(:dev), do: ["lib"]
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
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:decimal, "~> 2.0"},
      {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false},
      {:doctor, "~> 0.22.0", only: :dev},
      {:domo, "~> 1.5.10"},
      {:excoveralls, "~> 0.10", only: [:dev, :test]},
      {:ex_doc, "~> 0.27", only: :dev, runtime: false},
      {:ex_machina, "~> 2.8.0"},
      {:ex_unit_notifier, "~> 1.2", only: :test},
      {:faker, "~> 0.17", only: [:dev, :test]},
      {:gradient, github: "esl/gradient", only: [:dev], runtime: false},
      {:git_hooks, "~> 0.8.1", only: [:dev], runtime: false},
      {:math, "~> 0.7.0"},
      {:mix_audit, "~> 2.0", only: [:dev, :test], runtime: false},
      {:mix_test_watch, "~> 1.0", only: [:dev, :test], runtime: false},
      {:timex, "~> 3.7"},
      {:typed_struct, "~> 0.3.0"}
    ]
  end

  defp package do
    [
      files: ~w(lib mix.exs README.md LICENSE.md),
      maintainers: ["Slamet Kristanto"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/drselump14/azan_ex"
      }
    ]
  end
end
