import Config

if config_env() == :dev do
  config :git_hooks,
    auto_install: true,
    verbose: true,
    hooks: [
      pre_commit: [
        tasks: [
          {:cmd, "mix compile --warning-as-errors"},
          {:cmd, "mix format --check-formatted"},
          {:cmd, "mix credo --strict suggest"}
        ]
      ],
      pre_push: [
        tasks: [
          {:cmd, "mix dialyzer"},
          {:cmd, "mix test --color"},
          {:cmd, "echo 'success!'"}
        ]
      ]
    ]
end
