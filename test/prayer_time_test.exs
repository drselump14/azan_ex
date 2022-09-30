defmodule PrayerTimeTest do
  @moduledoc """
  Documentation for `PrayerTimeTest`.
  """

  use Azan.TestCase

  doctest PrayerTime

  describe "find/3" do
    setup do
      coordinate = %Coordinate{latitude: 35.775, longitude: -78.6336}

      %{
        coordinate: coordinate
      }
    end

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

    test "singapore method" do
      coordinate = Coordinate.new(3.7333333333, 101.3833333333)
      date = Date.new!(2015, 6, 14)

      params = CalculationMethod.singapore()

      %PrayerTime{
        fajr: fajr,
        sunrise: sunrise,
        dhuhr: dhuhr,
        asr: asr,
        maghrib: maghrib,
        isha: isha
      } = PrayerTime.find(coordinate, date, params)

      assert fajr |> tz_12_format_string("Asia/Kuala_Lumpur") == "5:41 AM"
      assert sunrise |> tz_12_format_string("Asia/Kuala_Lumpur") == "7:05 AM"
      assert dhuhr |> tz_12_format_string("Asia/Kuala_Lumpur") == "1:16 PM"
      assert asr |> tz_12_format_string("Asia/Kuala_Lumpur") == "4:42 PM"
      assert maghrib |> tz_12_format_string("Asia/Kuala_Lumpur") == "7:25 PM"
      assert isha |> tz_12_format_string("Asia/Kuala_Lumpur") == "8:41 PM"
    end

    test "getting the time for a given prayer" do
      coordinate = Coordinate.new(59.9094, 10.7349)
      date = Date.new!(2016, 7, 1)

      params = %{
        CalculationMethod.muslim_world_league()
        | madhab: :hanafi,
          high_latitude_rule: :twilight_angle
      }

      prayer_time =
        %PrayerTime{
          fajr: fajr,
          sunrise: sunrise,
          dhuhr: dhuhr,
          asr: asr,
          maghrib: maghrib,
          isha: isha
        } = PrayerTime.find(coordinate, date, params)

      assert prayer_time |> PrayerTime.time_for_prayer(:fajr) == fajr
      assert prayer_time |> PrayerTime.time_for_prayer(:sunrise) == sunrise
      assert prayer_time |> PrayerTime.time_for_prayer(:dhuhr) == dhuhr
      assert prayer_time |> PrayerTime.time_for_prayer(:asr) == asr
      assert prayer_time |> PrayerTime.time_for_prayer(:maghrib) == maghrib
      assert prayer_time |> PrayerTime.time_for_prayer(:isha) == isha
    end

    test "getting the current prayer" do
      coordinate = Coordinate.new(33.720817, 73.090032)
      date = Date.new!(2015, 9, 1)

      params = %{
        CalculationMethod.karachi()
        | madhab: :hanafi,
          high_latitude_rule: :twilight_angle
      }

      prayer_time =
        %PrayerTime{
          fajr: fajr,
          sunrise: sunrise,
          dhuhr: dhuhr,
          asr: asr,
          maghrib: maghrib,
          isha: isha
        } = PrayerTime.find(coordinate, date, params)

      assert prayer_time |> PrayerTime.current_prayer(fajr) == :fajr
      assert prayer_time |> PrayerTime.current_prayer(fajr |> Timex.shift(seconds: 1)) == :fajr
      assert prayer_time |> PrayerTime.current_prayer(fajr |> Timex.shift(seconds: -1)) == :none

      assert prayer_time |> PrayerTime.current_prayer(sunrise |> Timex.shift(seconds: 1)) ==
               :sunrise

      assert prayer_time |> PrayerTime.current_prayer(dhuhr |> Timex.shift(seconds: 1)) == :dhuhr
      assert prayer_time |> PrayerTime.current_prayer(asr |> Timex.shift(seconds: 1)) == :asr

      assert prayer_time |> PrayerTime.current_prayer(maghrib |> Timex.shift(seconds: 1)) ==
               :maghrib

      assert prayer_time |> PrayerTime.current_prayer(isha |> Timex.shift(seconds: 1)) == :isha
    end

    test "changing the time for asr with different madhabs" do
      coordinate = Coordinate.new(35.775, -78.6336)
      date = Date.new!(2015, 12, 1)

      params = CalculationMethod.muslim_world_league()

      %PrayerTime{asr: asr} = PrayerTime.find(coordinate, date, params)

      assert asr |> tz_12_format_string("America/New_York") == "2:42 PM"

      params = %{params | madhab: :hanafi}
      %PrayerTime{asr: asr} = PrayerTime.find(coordinate, date, params)
      assert asr |> tz_12_format_string("America/New_York") == "3:22 PM"
    end

    test "getting the next prayer" do
      coordinate = Coordinate.new(33.720817, 73.090032)
      date = Date.new!(2015, 9, 1)

      params = %{CalculationMethod.karachi() | madhab: :hanafi}

      prayer_time =
        %PrayerTime{
          fajr: fajr,
          sunrise: sunrise,
          dhuhr: dhuhr,
          asr: asr,
          maghrib: maghrib,
          isha: isha
        } = PrayerTime.find(coordinate, date, params)

      assert prayer_time |> PrayerTime.next_prayer(fajr |> Timex.shift(seconds: -1)) == :fajr
      assert prayer_time |> PrayerTime.next_prayer(fajr) == :sunrise
      assert prayer_time |> PrayerTime.next_prayer(fajr |> Timex.shift(seconds: 1)) == :sunrise
      assert prayer_time |> PrayerTime.next_prayer(sunrise |> Timex.shift(seconds: 1)) == :dhuhr
      assert prayer_time |> PrayerTime.next_prayer(dhuhr |> Timex.shift(seconds: 1)) == :asr
      assert prayer_time |> PrayerTime.next_prayer(asr |> Timex.shift(seconds: 1)) == :maghrib
      assert prayer_time |> PrayerTime.next_prayer(maghrib |> Timex.shift(seconds: 1)) == :isha
      assert prayer_time |> PrayerTime.next_prayer(isha |> Timex.shift(seconds: 1)) == :none
    end

    test "adjusting prayer time with high latitude rule" do
      coordinate = Coordinate.new(55.983226, -3.216649)
      date = Date.new!(2020, 6, 15)
      tzid = "Europe/London"
      params = CalculationMethod.muslim_world_league()

      %PrayerTime{
        fajr: fajr,
        sunrise: sunrise,
        dhuhr: dhuhr,
        asr: asr,
        maghrib: maghrib,
        isha: isha
      } = PrayerTime.find(coordinate, date, params)

      assert fajr |> tz_12_format_string(tzid) == "1:14 AM"
      assert sunrise |> tz_12_format_string(tzid) == "4:26 AM"
      assert dhuhr |> tz_12_format_string(tzid) == "1:14 PM"
      assert asr |> tz_12_format_string(tzid) == "5:46 PM"
      assert maghrib |> tz_12_format_string(tzid) == "10:01 PM"
      assert isha |> tz_12_format_string(tzid) == "1:14 AM"

      params = %{params | high_latitude_rule: :seventh_of_the_night}

      %PrayerTime{
        fajr: fajr,
        sunrise: sunrise,
        dhuhr: dhuhr,
        asr: asr,
        maghrib: maghrib,
        isha: isha
      } = PrayerTime.find(coordinate, date, params)

      assert fajr |> tz_12_format_string(tzid) == "3:31 AM"
      assert sunrise |> tz_12_format_string(tzid) == "4:26 AM"
      assert dhuhr |> tz_12_format_string(tzid) == "1:14 PM"
      assert asr |> tz_12_format_string(tzid) == "5:46 PM"
      assert maghrib |> tz_12_format_string(tzid) == "10:01 PM"
      assert isha |> tz_12_format_string(tzid) == "10:56 PM"

      params = %{params | high_latitude_rule: :twilight_angle}

      %PrayerTime{
        fajr: fajr,
        sunrise: sunrise,
        dhuhr: dhuhr,
        asr: asr,
        maghrib: maghrib,
        isha: isha
      } = PrayerTime.find(coordinate, date, params)

      assert fajr |> tz_12_format_string(tzid) == "2:31 AM"
      assert sunrise |> tz_12_format_string(tzid) == "4:26 AM"
      assert dhuhr |> tz_12_format_string(tzid) == "1:14 PM"
      assert asr |> tz_12_format_string(tzid) == "5:46 PM"
      assert maghrib |> tz_12_format_string(tzid) == "10:01 PM"
      assert isha |> tz_12_format_string(tzid) == "11:50 PM"
    end
  end

  describe "Moonsighting Committee method with shafaq general" do
    setup do
      coordinate = Coordinate.new(43.494, -79.844)
      params = %{CalculationMethod.moonsighting_committee() | shafaq: :general, madhab: :hanafi}

      %{
        coordinate: coordinate,
        params: params
      }
    end

    test "Shafaq general in winter", %{coordinate: coordinate, params: params} do
      date = Date.new!(2021, 1, 1)
      tzid = "America/New_York"

      %PrayerTime{
        fajr: fajr,
        sunrise: sunrise,
        dhuhr: dhuhr,
        asr: asr,
        maghrib: maghrib,
        isha: isha
      } = PrayerTime.find(coordinate, date, params)

      assert fajr |> tz_12_format_string(tzid) == "6:16 AM"
      assert sunrise |> tz_12_format_string(tzid) == "7:52 AM"
      assert dhuhr |> tz_12_format_string(tzid) == "12:28 PM"
      assert asr |> tz_12_format_string(tzid) == "3:12 PM"
      assert maghrib |> tz_12_format_string(tzid) == "4:57 PM"
      assert isha |> tz_12_format_string(tzid) == "6:27 PM"
    end

    test "Shafaq general in spring", %{coordinate: coordinate, params: params} do
      date = Date.new!(2021, 4, 1)
      tzid = "America/New_York"

      %PrayerTime{
        fajr: fajr,
        sunrise: sunrise,
        dhuhr: dhuhr,
        asr: asr,
        maghrib: maghrib,
        isha: isha
      } = PrayerTime.find(coordinate, date, params)

      assert fajr |> tz_12_format_string(tzid) == "5:28 AM"
      assert sunrise |> tz_12_format_string(tzid) == "7:01 AM"
      assert dhuhr |> tz_12_format_string(tzid) == "1:28 PM"
      assert asr |> tz_12_format_string(tzid) == "5:53 PM"
      assert maghrib |> tz_12_format_string(tzid) == "7:49 PM"
      assert isha |> tz_12_format_string(tzid) == "9:01 PM"
    end

    test "Shafaq general in summer", %{coordinate: coordinate, params: params} do
      date = Date.new!(2021, 7, 1)
      tzid = "America/New_York"

      %PrayerTime{
        fajr: fajr,
        sunrise: sunrise,
        dhuhr: dhuhr,
        asr: asr,
        maghrib: maghrib,
        isha: isha
      } = PrayerTime.find(coordinate, date, params)

      assert fajr |> tz_12_format_string(tzid) == "3:52 AM"
      assert sunrise |> tz_12_format_string(tzid) == "5:42 AM"
      assert dhuhr |> tz_12_format_string(tzid) == "1:28 PM"
      assert asr |> tz_12_format_string(tzid) == "6:42 PM"
      assert maghrib |> tz_12_format_string(tzid) == "9:07 PM"
      assert isha |> tz_12_format_string(tzid) == "10:22 PM"
    end

    test "Shafaq general in fall", %{coordinate: coordinate, params: params} do
      date = Date.new!(2021, 11, 1)
      tzid = "America/New_York"

      %PrayerTime{
        fajr: fajr,
        sunrise: sunrise,
        dhuhr: dhuhr,
        asr: asr,
        maghrib: maghrib,
        isha: isha
      } = PrayerTime.find(coordinate, date, params)

      assert fajr |> tz_12_format_string(tzid) == "6:22 AM"
      assert sunrise |> tz_12_format_string(tzid) == "7:55 AM"
      assert dhuhr |> tz_12_format_string(tzid) == "1:08 PM"
      assert asr |> tz_12_format_string(tzid) == "4:26 PM"
      assert maghrib |> tz_12_format_string(tzid) == "6:13 PM"
      assert isha |> tz_12_format_string(tzid) == "7:35 PM"
    end
  end

  describe "Moonsighting Committee method with shafaq ahmer" do
    setup do
      coordinate = Coordinate.new(43.494, -79.844)
      params = %{CalculationMethod.moonsighting_committee() | shafaq: :ahmer}

      %{
        coordinate: coordinate,
        params: params
      }
    end

    test "Shafaq ahmer in winter", %{coordinate: coordinate, params: params} do
      date = Date.new!(2021, 1, 1)
      tzid = "America/New_York"

      %PrayerTime{
        fajr: fajr,
        sunrise: sunrise,
        dhuhr: dhuhr,
        asr: asr,
        maghrib: maghrib,
        isha: isha
      } = PrayerTime.find(coordinate, date, params)

      assert fajr |> tz_12_format_string(tzid) == "6:16 AM"
      assert sunrise |> tz_12_format_string(tzid) == "7:52 AM"
      assert dhuhr |> tz_12_format_string(tzid) == "12:28 PM"
      assert asr |> tz_12_format_string(tzid) == "2:37 PM"
      assert maghrib |> tz_12_format_string(tzid) == "4:57 PM"
      assert isha |> tz_12_format_string(tzid) == "6:07 PM"
    end

    test "Shafaq ahmer in spring", %{coordinate: coordinate, params: params} do
      date = Date.new!(2021, 4, 1)
      tzid = "America/New_York"

      %PrayerTime{
        fajr: fajr,
        sunrise: sunrise,
        dhuhr: dhuhr,
        asr: asr,
        maghrib: maghrib,
        isha: isha
      } = PrayerTime.find(coordinate, date, params)

      assert fajr |> tz_12_format_string(tzid) == "5:28 AM"
      assert sunrise |> tz_12_format_string(tzid) == "7:01 AM"
      assert dhuhr |> tz_12_format_string(tzid) == "1:28 PM"
      assert asr |> tz_12_format_string(tzid) == "4:59 PM"
      assert maghrib |> tz_12_format_string(tzid) == "7:49 PM"
      assert isha |> tz_12_format_string(tzid) == "8:45 PM"
    end

    test "Shafaq ahmer in summer", %{coordinate: coordinate, params: params} do
      date = Date.new!(2021, 7, 1)
      tzid = "America/New_York"

      %PrayerTime{
        fajr: fajr,
        sunrise: sunrise,
        dhuhr: dhuhr,
        asr: asr,
        maghrib: maghrib,
        isha: isha
      } = PrayerTime.find(coordinate, date, params)

      assert fajr |> tz_12_format_string(tzid) == "3:52 AM"
      assert sunrise |> tz_12_format_string(tzid) == "5:42 AM"
      assert dhuhr |> tz_12_format_string(tzid) == "1:28 PM"
      assert asr |> tz_12_format_string(tzid) == "5:29 PM"
      assert maghrib |> tz_12_format_string(tzid) == "9:07 PM"
      assert isha |> tz_12_format_string(tzid) == "10:19 PM"
    end

    test "Shafaq ahmer in fall", %{coordinate: coordinate, params: params} do
      date = Date.new!(2021, 11, 1)
      tzid = "America/New_York"

      %PrayerTime{
        fajr: fajr,
        sunrise: sunrise,
        dhuhr: dhuhr,
        asr: asr,
        maghrib: maghrib,
        isha: isha
      } = PrayerTime.find(coordinate, date, params)

      assert fajr |> tz_12_format_string(tzid) == "6:22 AM"
      assert sunrise |> tz_12_format_string(tzid) == "7:55 AM"
      assert dhuhr |> tz_12_format_string(tzid) == "1:08 PM"
      assert asr |> tz_12_format_string(tzid) == "3:45 PM"
      assert maghrib |> tz_12_format_string(tzid) == "6:13 PM"
      assert isha |> tz_12_format_string(tzid) == "7:15 PM"
    end
  end

  describe "Moonsighting Committee method with shafaq abyad" do
    setup do
      coordinate = Coordinate.new(43.494, -79.844)
      params = %{CalculationMethod.moonsighting_committee() | shafaq: :abyad, madhab: :hanafi}

      %{
        coordinate: coordinate,
        params: params
      }
    end

    test "Shafaq abyad in winter", %{coordinate: coordinate, params: params} do
      date = Date.new!(2021, 1, 1)
      tzid = "America/New_York"

      %PrayerTime{
        fajr: fajr,
        sunrise: sunrise,
        dhuhr: dhuhr,
        asr: asr,
        maghrib: maghrib,
        isha: isha
      } = PrayerTime.find(coordinate, date, params)

      assert fajr |> tz_12_format_string(tzid) == "6:16 AM"
      assert sunrise |> tz_12_format_string(tzid) == "7:52 AM"
      assert dhuhr |> tz_12_format_string(tzid) == "12:28 PM"
      assert asr |> tz_12_format_string(tzid) == "3:12 PM"
      assert maghrib |> tz_12_format_string(tzid) == "4:57 PM"
      assert isha |> tz_12_format_string(tzid) == "6:28 PM"
    end

    test "Shafaq abyad in spring", %{coordinate: coordinate, params: params} do
      date = Date.new!(2021, 4, 1)
      tzid = "America/New_York"

      %PrayerTime{
        fajr: fajr,
        sunrise: sunrise,
        dhuhr: dhuhr,
        asr: asr,
        maghrib: maghrib,
        isha: isha
      } = PrayerTime.find(coordinate, date, params)

      assert fajr |> tz_12_format_string(tzid) == "5:28 AM"
      assert sunrise |> tz_12_format_string(tzid) == "7:01 AM"
      assert dhuhr |> tz_12_format_string(tzid) == "1:28 PM"
      assert asr |> tz_12_format_string(tzid) == "5:53 PM"
      assert maghrib |> tz_12_format_string(tzid) == "7:49 PM"
      assert isha |> tz_12_format_string(tzid) == "9:12 PM"
    end

    test "Shafaq abyad in summer", %{coordinate: coordinate, params: params} do
      date = Date.new!(2021, 7, 1)
      tzid = "America/New_York"

      %PrayerTime{
        fajr: fajr,
        sunrise: sunrise,
        dhuhr: dhuhr,
        asr: asr,
        maghrib: maghrib,
        isha: isha
      } = PrayerTime.find(coordinate, date, params)

      assert fajr |> tz_12_format_string(tzid) == "3:52 AM"
      assert sunrise |> tz_12_format_string(tzid) == "5:42 AM"
      assert dhuhr |> tz_12_format_string(tzid) == "1:28 PM"
      assert asr |> tz_12_format_string(tzid) == "6:42 PM"
      assert maghrib |> tz_12_format_string(tzid) == "9:07 PM"
      assert isha |> tz_12_format_string(tzid) == "11:17 PM"
    end

    test "Shafaq abyad in fall", %{coordinate: coordinate, params: params} do
      date = Date.new!(2021, 11, 1)
      tzid = "America/New_York"

      %PrayerTime{
        fajr: fajr,
        sunrise: sunrise,
        dhuhr: dhuhr,
        asr: asr,
        maghrib: maghrib,
        isha: isha
      } = PrayerTime.find(coordinate, date, params)

      assert fajr |> tz_12_format_string(tzid) == "6:22 AM"
      assert sunrise |> tz_12_format_string(tzid) == "7:55 AM"
      assert dhuhr |> tz_12_format_string(tzid) == "1:08 PM"
      assert asr |> tz_12_format_string(tzid) == "4:26 PM"
      assert maghrib |> tz_12_format_string(tzid) == "6:13 PM"
      assert isha |> tz_12_format_string(tzid) == "7:37 PM"
    end
  end

  describe "Polar cirle resolution cases" do
    setup do
      %{
        date_affected_by_midnight_sun:
          Timex.to_datetime({{2020, 6, 21}, {20, 0, 0}}, "Etc/UTC") |> Timex.to_date(),
        date_affected_by_polar_night:
          Timex.to_datetime({{2020, 12, 21}, {20, 0, 0}}, "Etc/UTC") |> Timex.to_date(),
        regular_coordinates: Coordinate.new(31.947351, 35.227163),
        arjeplog_sweden: Coordinate.new(66.7222444, 17.7189),
        amundsen_scott_antarctic: Coordinate.new(-84.996, 0.01013),
        unresolved_params: CalculationMethod.muslim_world_league(),
        aqrab_balad_params: %{
          CalculationMethod.muslim_world_league()
          | polar_circle_resolution: :aqrab_balad
        },
        aqrab_yaum_params: %{
          CalculationMethod.muslim_world_league()
          | polar_circle_resolution: :aqrab_yaum
        }
      }
    end

    test "midnight sun case should fail to compute targeted prayer times with the 'unresolved' resolver",
         %{
           arjeplog_sweden: arjeplog_sweden,
           date_affected_by_midnight_sun: date_affected_by_midnight_sun,
           unresolved_params: unresolved_params
         } do
      {:error, _} =
        PrayerTime.find(
          arjeplog_sweden,
          date_affected_by_midnight_sun,
          unresolved_params
        )
    end

    test "midnight sun case should fail to compute targeted prayer times with the 'aqrabBalad' resolver",
         %{
           arjeplog_sweden: arjeplog_sweden,
           date_affected_by_midnight_sun: date_affected_by_midnight_sun,
           aqrab_balad_params: aqrab_balad_params
         } do
      %PrayerTime{
        fajr: %DateTime{},
        sunrise: %DateTime{},
        dhuhr: %DateTime{},
        asr: %DateTime{},
        maghrib: %DateTime{},
        isha: %DateTime{}
      } =
        PrayerTime.find(
          arjeplog_sweden,
          date_affected_by_midnight_sun,
          aqrab_balad_params
        )
    end

    test "midnight sun case should fail to compute targeted prayer times with the 'aqrabYaum' resolver",
         %{
           arjeplog_sweden: arjeplog_sweden,
           date_affected_by_midnight_sun: date_affected_by_midnight_sun,
           aqrab_yaum_params: aqrab_yaum_params
         } do
      %PrayerTime{
        fajr: %DateTime{},
        sunrise: %DateTime{},
        dhuhr: %DateTime{},
        asr: %DateTime{},
        maghrib: %DateTime{},
        isha: %DateTime{}
      } =
        PrayerTime.find(
          arjeplog_sweden,
          date_affected_by_midnight_sun,
          aqrab_yaum_params
        )
    end

    test "polar night case should fail to compute targeted prayer times with the 'unresolved' resolver",
         %{
           amundsen_scott_antarctic: amundsen_scott_antarctic,
           date_affected_by_polar_night: date_affected_by_polar_night,
           unresolved_params: unresolved_params
         } do
      {:error, _} =
        PrayerTime.find(
          amundsen_scott_antarctic,
          date_affected_by_polar_night,
          unresolved_params
        )
    end

    test "polar night case should fail to compute targeted prayer times with the 'aqrabBalad' resolver",
         %{
           amundsen_scott_antarctic: amundsen_scott_antarctic,
           date_affected_by_polar_night: date_affected_by_polar_night,
           aqrab_balad_params: aqrab_balad_params
         } do
      %PrayerTime{
        fajr: %DateTime{},
        sunrise: %DateTime{},
        dhuhr: %DateTime{},
        asr: %DateTime{},
        maghrib: %DateTime{},
        isha: %DateTime{}
      } =
        PrayerTime.find(
          amundsen_scott_antarctic,
          date_affected_by_polar_night,
          aqrab_balad_params
        )
    end

    test "polar night case should fail to compute targeted prayer times with the 'aqrabYaum' resolver",
         %{
           amundsen_scott_antarctic: amundsen_scott_antarctic,
           date_affected_by_polar_night: date_affected_by_polar_night,
           aqrab_yaum_params: aqrab_yaum_params
         } do
      %PrayerTime{
        fajr: %DateTime{},
        sunrise: %DateTime{},
        dhuhr: %DateTime{},
        asr: %DateTime{},
        maghrib: %DateTime{},
        isha: %DateTime{}
      } =
        PrayerTime.find(
          amundsen_scott_antarctic,
          date_affected_by_polar_night,
          aqrab_yaum_params
        )
    end

    test "Polar night calculating times for the polar circle" do
      coordinate = Coordinate.new(66.7222444, 17.7189)
      date = Date.new!(2020, 6, 21)

      params = %{
        CalculationMethod.muslim_world_league()
        | polar_circle_resolution: :aqrab_yaum,
          high_latitude_rule: :seventh_of_the_night
      }

      %PrayerTime{
        fajr: fajr,
        sunrise: sunrise,
        dhuhr: dhuhr,
        asr: asr,
        maghrib: maghrib,
        isha: isha
      } = PrayerTime.find(coordinate, date, params)

      assert fajr |> tz_full_format_string("Europe/Stockholm") == "June 21, 2020 12:40 AM"
      assert sunrise |> tz_full_format_string("Europe/Stockholm") == "June 21, 2020 12:54 AM"
      assert dhuhr |> tz_full_format_string("Europe/Stockholm") == "June 21, 2020 12:55 PM"
      assert asr |> tz_full_format_string("Europe/Stockholm") == "June 21, 2020 5:49 PM"
      assert maghrib |> tz_full_format_string("Europe/Stockholm") == "June 21, 2020 11:36 PM"
      assert isha |> tz_full_format_string("Europe/Stockholm") == "June 21, 2020 11:51 PM"
    end
  end

  def tz_12_format_string(%DateTime{} = time, timezone) do
    time |> Timex.to_datetime(timezone) |> Timex.format!("{h12}:{m} {AM}")
  end

  def tz_full_format_string(%DateTime{} = time, timezone) do
    time |> Timex.to_datetime(timezone) |> Timex.format!("{Mfull} {D}, {YYYY} {h12}:{m} {AM}")
  end
end
