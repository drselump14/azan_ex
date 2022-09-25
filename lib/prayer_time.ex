defmodule PrayerTime do
  @moduledoc """
  Documentation for `PrayerTime`.
  """

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
        %CalculationParameter{} = calculation_parameter
      ) do
    tomorrow = date |> Timex.shift(days: 1)

    with {:ok,
          {%SolarTime{transit: transit, sunrise: sunrise, sunset: sunset} = solar_time,
           tomorrow_solar_time}} <-
           SolarTime.find_pair_solar_time(
             date,
             coordinate,
             calculation_parameter
           ),
         {:ok, sunrise_time} <-
           SunriseTime.find(sunrise, date, calculation_parameter, coordinate),
         {:ok, dhuhr_time} <- DhuhrTime.find(transit, date, calculation_parameter, coordinate),
         {:ok, asr_time} <- AsrTime.find(solar_time, date, calculation_parameter),
         {:ok, tomorrow_sunrise} <-
           SunriseTime.find(tomorrow_solar_time.sunrise, tomorrow, coordinate),
         {:ok, sunset_time} <- SunsetTime.find(sunset, date, calculation_parameter, coordinate),
         {:ok, night} <- calculate_night(tomorrow_sunrise, sunset_time),
         {:ok, isha_time} <-
           IshaTime.find(solar_time, sunset_time, night, latitude, date, calculation_parameter),
         {:ok, fajr_time} <-
           FajrTime.find(solar_time, sunrise_time, night, latitude, date, calculation_parameter),
         {:ok, maghrib_time} <-
           MaghribTime.find(solar_time, sunset_time, isha_time, date, calculation_parameter) do
      %__MODULE__{
        fajr: fajr_time |> FajrTime.adjust(calculation_parameter),
        sunrise: sunrise_time |> SunriseTime.adjust(calculation_parameter),
        dhuhr: dhuhr_time |> DhuhrTime.adjust(calculation_parameter),
        asr: asr_time |> AsrTime.adjust(calculation_parameter),
        sunset: sunset_time |> SunsetTime.adjust(calculation_parameter),
        maghrib: maghrib_time |> MaghribTime.adjust(calculation_parameter),
        isha: isha_time |> IshaTime.adjust(calculation_parameter)
      }
    else
      {:error, reason} ->
        {:error, reason}
    end
  end

  @spec time_for_prayer(PrayerTime.t(), atom()) :: DateTime.t()
  def time_for_prayer(%__MODULE__{} = prayer_time, prayer_name) do
    prayer_time
    |> Map.get(prayer_name)
  end

  def current_prayer(
        %__MODULE__{
          fajr: fajr,
          sunrise: sunrise,
          dhuhr: dhuhr,
          asr: asr,
          maghrib: maghrib,
          isha: isha
        },
        time
      ) do
    fajr_epoch = fajr |> Timex.to_unix()
    sunrise_epoch = sunrise |> Timex.to_unix()
    dhuhr_epoch = dhuhr |> Timex.to_unix()
    asr_epoch = asr |> Timex.to_unix()
    maghrib_epoch = maghrib |> Timex.to_unix()
    isha_epoch = isha |> Timex.to_unix()

    case time |> Timex.to_unix() do
      x when x >= fajr_epoch -> :fajr
      x when x >= isha_epoch -> :isha
      x when x >= maghrib_epoch -> :maghrib
      x when x >= asr_epoch -> :asr
      x when x >= dhuhr_epoch -> :dhuhr
      x when x >= sunrise_epoch -> :sunrise
      _ -> :none
    end
  end

  def next_prayer(
        %__MODULE__{
          fajr: fajr,
          sunrise: sunrise,
          dhuhr: dhuhr,
          asr: asr,
          maghrib: maghrib,
          isha: isha
        },
        time
      ) do
    fajr_epoch = fajr |> Timex.to_unix()
    sunrise_epoch = sunrise |> Timex.to_unix()
    dhuhr_epoch = dhuhr |> Timex.to_unix()
    asr_epoch = asr |> Timex.to_unix()
    maghrib_epoch = maghrib |> Timex.to_unix()
    isha_epoch = isha |> Timex.to_unix()

    case time |> Timex.to_unix() do
      x when x >= fajr_epoch -> :sunrise
      x when x >= isha_epoch -> :fajr
      x when x >= maghrib_epoch -> :isha
      x when x >= asr_epoch -> :maghrib
      x when x >= dhuhr_epoch -> :asr
      x when x >= sunrise_epoch -> :dhuhr
      _ -> :none
    end
  end

  def rounded_time(prayer_time, adjustment, rounding) do
    prayer_time
    |> Timex.shift(minutes: adjustment)
    |> DateUtils.rounded_minute(rounding)
  end

  def calculate_night({:error, _}, _sunset_time), do: {:error, :invalid}
  def calculate_night(_tomorrow_sunrise, {:error, _}), do: {:error, :invalid}

  def calculate_night(tomorrow_sunrise, sunset_time) do
    {:ok, Timex.to_unix(tomorrow_sunrise) - Timex.to_unix(sunset_time)}
  end
end
