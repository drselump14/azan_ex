defmodule Azan.FajrTime do
  @moduledoc """
  Documentation for `FajrTime`.
  """

  use TypedStruct

  alias Azan.{
    CalculationParameter,
    DateUtils,
    SafeFajr,
    SolarTime,
    TimeComponent
  }

  typedstruct do
    field :calculation_parameter, CalculationParameter.t()
    field :sunrise_time, DateTime.t()
    field :night, number()
    field :latitude, number()
    field :date, Date.t()
    field :solar_time, SolarTime.t()
  end

  def find(
        solar_time,
        sunrise_time,
        night,
        latitude,
        date,
        %CalculationParameter{} = calculation_parameter
      ) do
    case %__MODULE__{
           calculation_parameter: calculation_parameter,
           sunrise_time: sunrise_time,
           solar_time: solar_time,
           night: night,
           latitude: latitude,
           date: date
         }
         |> __MODULE__.find!() do
      %DateTime{} = fajr_time ->
        {:ok, fajr_time}

      {:error, error} ->
        {:error, error}
    end
  end

  def find!(%__MODULE__{
        calculation_parameter:
          %CalculationParameter{method: method, fajr_angle: fajr_angle} = calculation_parameter,
        solar_time: solar_time,
        sunrise_time: sunrise_time,
        night: night,
        latitude: latitude,
        date: date
      }) do
    naive_fajr_time =
      solar_time
      |> naive_fajr_time(fajr_angle, date)
      |> consider_latitude_and_method(night, method, latitude)

    safe_fajr_time =
      %SafeFajr{
        calculation_parameter: calculation_parameter,
        sunrise_time: sunrise_time,
        night: night,
        latitude: latitude,
        date: date
      }
      |> SafeFajr.find_time()

    naive_fajr_time |> naive_or_safe_fajr(safe_fajr_time)
  end

  def naive_fajr_time(%SolarTime{} = solar_time, fajr_angle, date) do
    case solar_time |> SolarTime.hour_angle(-1 * fajr_angle, false) do
      {:error, _} ->
        {:error, :invalid_datetime}

      corrected_hour_angle ->
        corrected_hour_angle
        |> TimeComponent.new()
        |> TimeComponent.create_utc_datetime(date)
    end
  end

  @spec consider_latitude_and_method(DateTime.t(), number, atom(), number()) :: DateTime.t()
  def consider_latitude_and_method(fajr_time, night, :moonsighting_committee, latitude)
      when latitude >= 55 do
    night_fraction = night / 7
    fajr_time |> DateUtils.shift_by_seconds(-1 * night_fraction)
  end

  def consider_latitude_and_method(fajr_time, _night, _method, _latitude), do: fajr_time

  def naive_or_safe_fajr({:error, :invalid_datetime}, safe_fajr_time), do: safe_fajr_time

  def naive_or_safe_fajr(naive_fajr_time, safe_fajr_time) do
    case DateTime.compare(safe_fajr_time, naive_fajr_time) do
      :gt -> safe_fajr_time
      _ -> naive_fajr_time
    end
  end

  def adjust(datetime, %CalculationParameter{
        adjustments: %{fajr: adjustment},
        method_adjustments: %{fajr: method_adjustment},
        rounding: rounding
      }) do
    adjustment = adjustment |> DateUtils.sum_adjustment(method_adjustment)
    datetime |> DateUtils.rounded_time(adjustment, rounding)
  end
end
