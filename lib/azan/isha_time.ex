defmodule Azan.IshaTime do
  @moduledoc """
  Documentation for `IshaTime`.
  """

  use TypedStruct

  alias Azan.{
    CalculationParameter,
    DateUtils,
    SafeIsha,
    SolarTime,
    TimeComponent
  }

  typedstruct do
    field :solar_time, SolarTime.t()
    field :date, Date.t()
    field :calculation_parameter, CalculationParameter.t()
    field :sunset_time, DateTime.t()
    field :latitude, number()
    field :night, number()
  end

  def find(
        solar_time,
        sunset_time,
        night,
        latitude,
        date,
        %CalculationParameter{} = calculation_parameter
      ) do
    {:ok,
     %__MODULE__{
       calculation_parameter: calculation_parameter,
       sunset_time: sunset_time,
       solar_time: solar_time,
       night: night,
       latitude: latitude,
       date: date
     }
     |> __MODULE__.find!()}
  end

  def find!(%__MODULE__{
        sunset_time: sunset_time,
        calculation_parameter: %CalculationParameter{isha_interval: isha_interval}
      })
      when isha_interval > 0 do
    sunset_time |> Timex.shift(minutes: isha_interval)
  end

  def find!(
        %__MODULE__{
          calculation_parameter: calculation_parameter,
          night: night,
          latitude: latitude,
          date: date,
          sunset_time: sunset_time
        } = isha_time_struct
      ) do
    naive_isha_time = isha_time_struct |> find_naive_time()

    safe_isha_time =
      %SafeIsha{
        calculation_parameter: calculation_parameter,
        night: night,
        latitude: latitude,
        date: date,
        sunset_time: sunset_time
      }
      |> SafeIsha.find()

    naive_isha_time |> naive_or_safe_isha(safe_isha_time)
  end

  def find_naive_time(%__MODULE__{
        calculation_parameter: %CalculationParameter{method: :moonsighting_committee},
        sunset_time: sunset_time,
        night: night,
        latitude: latitude
      })
      when latitude >= 55 do
    night_fraction = night / 7
    sunset_time |> DateUtils.shift_by_seconds(night_fraction)
  end

  def find_naive_time(%__MODULE__{
        calculation_parameter: %CalculationParameter{isha_angle: isha_angle},
        date: date,
        solar_time: solar_time
      }) do
    case solar_time |> SolarTime.hour_angle(-1 * isha_angle, true) do
      {:error, _} ->
        {:error, :invalid_datetime}

      corrected_hour_angle ->
        corrected_hour_angle
        |> TimeComponent.new()
        |> TimeComponent.create_utc_datetime(date)
    end
  end

  def naive_or_safe_isha({:error, _}, safe_isha), do: safe_isha

  def naive_or_safe_isha(naive_isha_time, safe_isha_time) do
    case DateTime.compare(safe_isha_time, naive_isha_time) do
      :lt ->
        safe_isha_time

      _ ->
        naive_isha_time
    end
  end

  def adjust(datetime, %CalculationParameter{
        adjustments: %{isha: adjustment},
        method_adjustments: %{isha: method_adjustment},
        rounding: rounding
      }) do
    adjustment = adjustment |> DateUtils.sum_adjustment(method_adjustment)
    datetime |> DateUtils.rounded_time(adjustment, rounding)
  end
end
