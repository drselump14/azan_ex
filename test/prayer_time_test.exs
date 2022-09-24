defmodule PrayerTimeTest do
  @moduledoc """
  Documentation for `PrayerTimeTest`.
  """

  use Azan.TestCase

  doctest PrayerTime

  setup do
    coordinate = %Coordinate{latitude: 35.775, longitude: -78.6336}

    %{
      coordinate: coordinate
    }
  end

  describe "find/3" do
    test "moonsighting_committee", %{coordinate: coordinate} do
      date = Date.new!(2016, 1, 31)
      params = CalculationMethod.moonsighting_committee()

      %PrayerTime{
        fajr: fajr,
        sunrise: sunrise,
        dhuhr: dhuhr,
        asr: asr,
        maghrib: maghrib,
        isha: isha
      } = PrayerTime.find(coordinate, date, params)

      assert fajr |> tz_12_format_string("America/New_York") == "5:48 AM"
      assert sunrise |> tz_12_format_string("America/New_York") == "7:16 AM"
      assert dhuhr |> tz_12_format_string("America/New_York") == "12:33 PM"
      assert asr |> tz_12_format_string("America/New_York") == "3:20 PM"
      assert maghrib |> tz_12_format_string("America/New_York") == "5:43 PM"
      assert isha |> tz_12_format_string("America/New_York") == "7:05 PM"
    end

    test "north_america", %{coordinate: coordinate} do
      date = Date.new!(2015, 7, 12)
      params = %{CalculationMethod.north_america() | madhab: :hanafi}

      %PrayerTime{
        fajr: fajr,
        sunrise: sunrise,
        dhuhr: dhuhr,
        asr: asr,
        maghrib: maghrib,
        isha: isha
      } = PrayerTime.find(coordinate, date, params)

      assert fajr |> tz_12_format_string("America/New_York") == "4:42 AM"
      assert sunrise |> tz_12_format_string("America/New_York") == "6:08 AM"
      assert dhuhr |> tz_12_format_string("America/New_York") == "1:21 PM"
      assert asr |> tz_12_format_string("America/New_York") == "6:22 PM"
      assert maghrib |> tz_12_format_string("America/New_York") == "8:32 PM"
      assert isha |> tz_12_format_string("America/New_York") == "9:57 PM"
    end

    test "muslim_world_league", %{coordinate: coordinate} do
      date = Date.new!(2015, 12, 1)
      params = CalculationMethod.muslim_world_league()

      %PrayerTime{
        fajr: fajr,
        sunrise: sunrise,
        dhuhr: dhuhr,
        asr: asr,
        maghrib: maghrib,
        isha: isha
      } = PrayerTime.find(coordinate, date, params)

      assert fajr |> tz_12_format_string("America/New_York") == "5:35 AM"
      assert sunrise |> tz_12_format_string("America/New_York") == "7:06 AM"
      assert dhuhr |> tz_12_format_string("America/New_York") == "12:05 PM"
      assert asr |> tz_12_format_string("America/New_York") == "2:42 PM"
      assert maghrib |> tz_12_format_string("America/New_York") == "5:01 PM"
      assert isha |> tz_12_format_string("America/New_York") == "6:26 PM"
    end

    test "with adjustment", %{coordinate: coordinate} do
      date = Date.new!(2015, 12, 1)

      params = %{
        CalculationMethod.muslim_world_league()
        | adjustments: %{fajr: 10, sunrise: 10, dhuhr: 10, asr: 10, maghrib: 10, isha: 10}
      }

      %PrayerTime{
        fajr: fajr,
        sunrise: sunrise,
        dhuhr: dhuhr,
        asr: asr,
        maghrib: maghrib,
        isha: isha
      } = PrayerTime.find(coordinate, date, params)

      assert fajr |> tz_12_format_string("America/New_York") == "5:45 AM"
      assert sunrise |> tz_12_format_string("America/New_York") == "7:16 AM"
      assert dhuhr |> tz_12_format_string("America/New_York") == "12:15 PM"
      assert asr |> tz_12_format_string("America/New_York") == "2:52 PM"
      assert maghrib |> tz_12_format_string("America/New_York") == "5:11 PM"
      assert isha |> tz_12_format_string("America/New_York") == "6:36 PM"
    end

    test "moonsighting_committee at high latitude location", _context do
      coordinate = %Coordinate{latitude: 59.9094, longitude: 10.7349}
      date = Date.new!(2016, 1, 1)

      params = %{CalculationMethod.moonsighting_committee() | madhab: :hanafi}

      %PrayerTime{
        fajr: fajr,
        sunrise: sunrise,
        dhuhr: dhuhr,
        asr: asr,
        maghrib: maghrib,
        isha: isha
      } = PrayerTime.find(coordinate, date, params)

      assert fajr |> tz_12_format_string("Europe/Oslo") == "7:34 AM"
      assert sunrise |> tz_12_format_string("Europe/Oslo") == "9:19 AM"
      assert dhuhr |> tz_12_format_string("Europe/Oslo") == "12:25 PM"
      assert asr |> tz_12_format_string("Europe/Oslo") == "1:36 PM"
      assert maghrib |> tz_12_format_string("Europe/Oslo") == "3:25 PM"
      assert isha |> tz_12_format_string("Europe/Oslo") == "5:02 PM"
    end

    test "turkey method" do
      coordinate = %Coordinate{latitude: 41.005616, longitude: 28.97638}
      date = Date.new!(2020, 4, 16)

      params = CalculationMethod.turkey()

      %PrayerTime{
        fajr: fajr,
        sunrise: sunrise,
        dhuhr: dhuhr,
        asr: asr,
        maghrib: maghrib,
        isha: isha
      } = PrayerTime.find(coordinate, date, params)

      assert fajr |> tz_12_format_string("Europe/Istanbul") == "4:44 AM"
      assert sunrise |> tz_12_format_string("Europe/Istanbul") == "6:16 AM"
      assert dhuhr |> tz_12_format_string("Europe/Istanbul") == "1:09 PM"
      assert asr |> tz_12_format_string("Europe/Istanbul") == "4:53 PM"
      assert maghrib |> tz_12_format_string("Europe/Istanbul") == "7:52 PM"
      assert isha |> tz_12_format_string("Europe/Istanbul") == "9:19 PM"
    end

    test "egyptian method" do
      coordinate = %Coordinate{latitude: 30.028703, longitude: 31.249528}
      date = Date.new!(2020, 1, 1)

      params = CalculationMethod.egyptian()

      %PrayerTime{
        fajr: fajr,
        sunrise: sunrise,
        dhuhr: dhuhr,
        asr: asr,
        maghrib: maghrib,
        isha: isha
      } = PrayerTime.find(coordinate, date, params)

      assert fajr |> tz_12_format_string("Africa/Cairo") == "5:18 AM"
      assert sunrise |> tz_12_format_string("Africa/Cairo") == "6:51 AM"
      assert dhuhr |> tz_12_format_string("Africa/Cairo") == "11:59 AM"
      assert asr |> tz_12_format_string("Africa/Cairo") == "2:47 PM"
      assert maghrib |> tz_12_format_string("Africa/Cairo") == "5:06 PM"
      assert isha |> tz_12_format_string("Africa/Cairo") == "6:29 PM"
    end
  end

  def tz_12_format_string(%DateTime{} = time, timezone) do
    time |> Timex.to_datetime(timezone) |> Timex.format!("{h12}:{m} {AM}")
  end
end
