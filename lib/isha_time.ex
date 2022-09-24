defmodule IshaTime do
  @moduledoc """
  Documentation for `IshaTime`.
  """

  use TypedStruct

  typedstruct do
    field :solar_time, SolarTime.t()
    field :date, Date.t()
    field :calculation_parameter, CalculationParameter.t()
    field :sunset_time, DateTime.t()
    field :latitude, number()
    field :night, number()
  end

  def find(%__MODULE__{
        sunset_time: sunset_time,
        calculation_parameter: %CalculationParameter{isha_interval: isha_interval}
      })
      when isha_interval > 0 do
    sunset_time |> Timex.shift(minutes: isha_interval)
  end

  def find(
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
    solar_time
    |> SolarTime.hour_angle(-1 * isha_angle, true)
    |> TimeComponent.new()
    |> TimeComponent.create_utc_datetime(date)
  end

  def naive_or_safe_isha({:error, :invalid_date}, safe_isha), do: safe_isha

  def naive_or_safe_isha(naive_isha_time, safe_isha_time) do
    case DateTime.compare(safe_isha_time, naive_isha_time) do
      :lt ->
        safe_isha_time

      _ ->
        naive_isha_time
    end
  end
end
