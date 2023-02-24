defmodule Azan.PrayerTime do
  @moduledoc """
  Documentation for `PrayerTime`.
  """

  alias Azan.{
    AsrTime,
    CalculationParameter,
    Coordinate,
    DateUtils,
    DhuhrTime,
    FajrTime,
    IshaTime,
    MaghribTime,
    PrayerTime,
    SolarTime,
    SunriseTime,
    SunsetTime
  }

  use TypedStruct

  require Logger

  typedstruct do
    field :fajr, DateTime.t()
    field :sunrise, DateTime.t()
    field :dhuhr, DateTime.t()
    field :asr, DateTime.t()
    field :sunset, DateTime.t()
    field :maghrib, DateTime.t()
    field :isha, DateTime.t()
  end

  @doc """
  Returns a `PrayerTime` struct for the given `date`, `coordinate` and `calculation_parameter`.

      ## Examples

      iex> date = ~D[2022-10-01]
      ~D[2022-10-01]
      iex> coordinate = %Azan.Coordinate{latitude: 35.671494, longitude: 139.90181}
      %Azan.Coordinate{latitude: 35.671494, longitude: 139.90181}
      iex> params = CalculationMethod.moonsighting_committee()
      %Azan.CalculationParameter{
        adjustments: %{asr: 0, dhuhr: 0, fajr: 0, isha: 0, maghrib: 0, sunrise: 0},
        fajr_angle: 18.0,
        high_latitude_rule: :middle_of_the_night,
        isha_angle: 18.0,
        isha_interval: 0,
        madhab: :shafi,
        maghrib_angle: 0.0,
        method: :moonsighting_committee,
        method_adjustments: %{
          asr: 0,
          dhuhr: 5,
          fajr: 0,
          isha: 0,
          maghrib: 3,
          sunrise: 0
        },
        polar_circle_resolution: :unresolved,
        rounding: :nearest,
        shafaq: :general
      }
      iex> coordinate |> PrayerTime.find(date, params)
      %Azan.PrayerTime{
        asr: ~U[2022-10-01 05:51:00Z],
        dhuhr: ~U[2022-10-01 02:35:00Z],
        fajr: ~U[2022-09-30 19:10:00Z],
        isha: ~U[2022-10-01 09:43:00Z],
        maghrib: ~U[2022-10-01 08:28:00Z],
        sunrise: ~U[2022-09-30 20:35:00Z],
        sunset: ~U[2022-10-01 08:25:00Z]
      }

  """
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
           SunriseTime.find_naive_time(tomorrow_solar_time.sunrise, tomorrow),
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

  @doc """
  Returns prayer time for prayer name

      ## Examples

      iex> prayer_time = %Azan.PrayerTime{
      ...>               asr: ~U[2022-10-01 05:51:00Z],
      ...>               dhuhr: ~U[2022-10-01 02:35:00Z],
      ...>               fajr: ~U[2022-09-30 19:10:00Z],
      ...>               isha: ~U[2022-10-01 09:43:00Z],
      ...>               maghrib: ~U[2022-10-01 08:28:00Z],
      ...>               sunrise: ~U[2022-09-30 20:35:00Z],
      ...>               sunset: ~U[2022-10-01 08:25:00Z]
      ...>             }
      iex> prayer_time |> PrayerTime.time_for_prayer(:fajr)
      ~U[2022-09-30 19:10:00Z]
  """
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
      x when x >= isha_epoch -> :isha
      x when x >= maghrib_epoch -> :maghrib
      x when x >= asr_epoch -> :asr
      x when x >= dhuhr_epoch -> :dhuhr
      x when x >= sunrise_epoch -> :sunrise
      x when x >= fajr_epoch -> :fajr
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
      x when x >= isha_epoch -> :none
      x when x >= maghrib_epoch -> :isha
      x when x >= asr_epoch -> :maghrib
      x when x >= dhuhr_epoch -> :asr
      x when x >= sunrise_epoch -> :dhuhr
      x when x >= fajr_epoch -> :sunrise
      _ -> :fajr
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
    with {:ok, tomorrow_sunrice_epoch} <-
           tomorrow_sunrise |> Timex.to_unix() |> DateUtils.wrap_timex_error(),
         {:ok, sunset_epoch} <- sunset_time |> Timex.to_unix() |> DateUtils.wrap_timex_error() do
      {:ok, tomorrow_sunrice_epoch - sunset_epoch}
    else
      error -> error
    end
  end
end
