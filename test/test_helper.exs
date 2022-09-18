ExUnit.configure(formatters: [ExUnit.CLIFormatter, ExUnitNotifier])
Faker.start()
{:ok, _} = Application.ensure_all_started(:ex_machina)
ExUnit.start()
