defmodule PrayerTimeTest do
  @moduledoc """
  Documentation for `PrayerTimeTest`.
  """

  use Azan.TestCase

  doctest PrayerTime

  test "find" do
    coordinates = %Coordinate{latitude: 35.775, longitude: -78.6336}
    date = Date.new!(2016, 1, 31)
    params = CalculationMethod.moonsighting_committee()

    %PrayerTime{
      fajr: fajr,
      sunrise: sunrise,
      dhuhr: dhuhr,
      asr: asr,
      maghrib: maghrib,
      isha: isha
    } = PrayerTime.find(coordinates, date, params)

    assert fajr |> tz_12_format_string("America/New_York") == "5:48 AM"
    assert sunrise |> tz_12_format_string("America/New_York") == "7:16 AM"
    assert dhuhr |> tz_12_format_string("America/New_York") == "12:33 PM"
    assert asr |> tz_12_format_string("America/New_York") == "3:20 PM"
    assert maghrib |> tz_12_format_string("America/New_York") == "5:43 PM"
    assert isha |> tz_12_format_string("America/New_York") == "7:05 PM"
  end

  def tz_12_format_string(%DateTime{} = time, timezone) do
    time |> Timex.to_datetime(timezone) |> Timex.format!("{h12}:{m} {AM}")
  end
end
