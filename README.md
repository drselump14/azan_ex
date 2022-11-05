# Azan

Calculate Azan for given time & location

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `azan_ex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:azan_ex, "~> 0.1.0"}
  ]
end
```

The docs be found at <https://hexdocs.pm/azan_ex>.

## Usage

```elixir
  date = DateTime.utc_now() |> DateTime.to_date()
  coordinate = %Azan.Coordinate{latitude: 35.671494 , longitude: 139.901810}
  params = Azan.CalculationMethod.moonsighting_committee()

  prayer_time = coordinate |> Azan.PrayerTime.find(date, params)

  iex> %Azan.PrayerTime{
    asr: ~U[2022-10-01 05:51:00Z],
    dhuhr: ~U[2022-10-01 02:35:00Z],
    fajr: ~U[2022-09-30 19:10:00Z],
    isha: ~U[2022-10-01 09:43:00Z],
    maghrib: ~U[2022-10-01 08:28:00Z],
    sunrise: ~U[2022-09-30 20:35:00Z],
    sunset: ~U[2022-10-01 08:25:00Z]
  }
```

or try using livebook

```bash
livebook server USAGE.livemd
```
