use ExGuard.Config

guard("unit-test", run_on_start: true)
|> command("mix test --color")
|> watch({~r{lib/(?<file>.+).ex$}i, fn m -> "test/#{m["file"]}_test.exs" end})
|> watch({~r{test/(?<file>.+)_test.exs$}i, fn m -> "test/#{m["file"]}_test.exs" end})
|> ignore(~r{deps})
|> ignore(~r{mix.exs})
|> notification(:auto)

# guard("credo", run_on_start: true)
# |> command("mix credo --strict suggest")
# |> watch(~r{\.(erl|ex|exs|eex|xrl|yrl|)\z}i)
# |> ignore(~r{deps})
# |> notification(:auto)
