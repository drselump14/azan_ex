defmodule PrayerTime do
  @moduledoc """
  Documentation for `PrayerTime`.
  """

  require Logger
  use TypedStruct

  typedstruct do
    field :fajr, DateTime.t()
    field :sunrise, DateTime.t()
    field :dhuhr, DateTime.t()
    field :asr, DateTime.t()
    field :sunset, DateTime.t()
    field :maghrib, DateTime.t()
    field :isha, DateTime.t()
  end

  def find(
        %Coordinate{latitude: latitude} = coordinate,
        date,
        %CalculationParameter{
          adjustments: adjustments,
          method_adjustments: method_adjustments,
          rounding: rounding
        } = calculation_parameter
      ) do
    solar_time =
      %SolarTime{transit: transit, sunrise: sunrise, sunset: sunset} =
      SolarTime.new(date, coordinate)

    tomorrow = date |> Timex.shift(days: 1)

    tomorrow_solar_time = SolarTime.new(tomorrow, coordinate)

    tomorrow_sunrise =
      tomorrow_solar_time.sunrise
      |> TimeComponent.new()
      |> TimeComponent.create_utc_datetime(tomorrow.year, tomorrow.month, tomorrow.day)

    sunrise_time =
      %SunriseTime{
        sunrise: sunrise,
        date: date,
        calculation_parameter: calculation_parameter,
        coordinate: coordinate
      }
      |> SunriseTime.find()

    dhuhr_time =
      %DhuhrTime{
        transit: transit,
        date: date,
        calculation_parameter: calculation_parameter,
        coordinate: coordinate
      }
      |> DhuhrTime.find()

    asr_time =
      %AsrTime{
        solar_time: solar_time,
        calculation_parameter: calculation_parameter,
        date: date
      }
      |> AsrTime.find()

    sunset_time =
      %SunsetTime{
        sunset: sunset,
        date: date,
        calculation_parameter: calculation_parameter,
        coordinate: coordinate
      }
      |> SunsetTime.find()

    night = calculate_night(tomorrow_sunrise, sunset_time)

    fajr_time =
      %FajrTime{
        calculation_parameter: calculation_parameter,
        sunrise_time: sunrise_time,
        solar_time: solar_time,
        night: night,
        latitude: latitude,
        date: date
      }
      |> FajrTime.find()

    isha_time =
      %IshaTime{
        solar_time: solar_time,
        date: date,
        calculation_parameter: calculation_parameter,
        sunset_time: sunset_time,
        latitude: latitude,
        night: night
      }
      |> IshaTime.find()

    maghrib_time =
      %MaghribTime{
        solar_time: solar_time,
        sunset_time: sunset_time,
        calculation_parameter: calculation_parameter,
        isha_time: isha_time,
        date: date
      }
      |> MaghribTime.find()

    fajr_adjustment = adjustments.fajr |> sum_adjustment(method_adjustments.fajr)
    sunrise_adjustment = adjustments.sunrise |> sum_adjustment(method_adjustments.sunrise)
    dhuhr_adjustment = adjustments.dhuhr |> sum_adjustment(method_adjustments.dhuhr)
    asr_adjustment = adjustments.asr |> sum_adjustment(method_adjustments.asr)
    maghrib_adjustment = adjustments.maghrib |> sum_adjustment(method_adjustments.maghrib)
    isha_adjustment = adjustments.isha |> sum_adjustment(method_adjustments.isha)

    %__MODULE__{
      fajr: fajr_time |> rounded_time(fajr_adjustment, rounding),
      sunrise: sunrise_time |> rounded_time(sunrise_adjustment, rounding),
      dhuhr: dhuhr_time |> rounded_time(dhuhr_adjustment, rounding),
      asr: asr_time |> rounded_time(asr_adjustment, rounding),
      sunset: sunset_time |> DateUtils.rounded_minute(rounding),
      maghrib: maghrib_time |> rounded_time(maghrib_adjustment, rounding),
      isha: isha_time |> rounded_time(isha_adjustment, rounding)
    }
  end

  def rounded_time(prayer_time, adjustment, rounding) do
    prayer_time
    |> Timex.shift(minutes: adjustment)
    |> DateUtils.rounded_minute(rounding)
  end

  def calculate_night(tomorrow_sunrise, sunset_time) do
    (Timex.to_unix(tomorrow_sunrise) - Timex.to_unix(sunset_time)) / 1000
  end

  def sum_adjustment(nil, nil), do: 0
  def sum_adjustment(adjustment_1, nil), do: adjustment_1
  def sum_adjustment(nil, adjustment_2), do: adjustment_2
  def sum_adjustment(adjustment_1, adjustment_2), do: adjustment_1 + adjustment_2
end
