defmodule MaghribTime do
  @moduledoc """
  Documentation for `MaghribTime`.
  """

  use TypedStruct

  typedstruct do
    field :solar_time, SolarTime.t()
    field :sunset_time, DateTime.t()
    field :calculation_parameter, CalculationParameter.t()
    field :isha_time, DateTime.t()
    field :date, Date.t()
  end

  def find(
        solar_time,
        sunset_time,
        isha_time,
        date,
        %CalculationParameter{} = calculation_parameter
      ) do
    {:ok,
     %__MODULE__{
       solar_time: solar_time,
       sunset_time: sunset_time,
       calculation_parameter: calculation_parameter,
       isha_time: isha_time,
       date: date
     }
     |> __MODULE__.find!()}
  end

  def find!(%__MODULE__{
        sunset_time: sunset_time,
        calculation_parameter: %CalculationParameter{maghrib_angle: maghrib_angle}
      })
      when is_nil(maghrib_angle) or maghrib_angle == 0,
      do: sunset_time

  def find!(%__MODULE__{
        solar_time: solar_time,
        sunset_time: sunset_time,
        isha_time: isha_time,
        calculation_parameter: %CalculationParameter{maghrib_angle: maghrib_angle},
        date: date
      }) do
    angle_based_maghrib_time = solar_time |> adjust_maghrib_angle(maghrib_angle, date)

    if sunset_time < angle_based_maghrib_time && isha_time > angle_based_maghrib_time,
      do: angle_based_maghrib_time,
      else: sunset_time
  end

  def adjust_maghrib_angle(solar_time, maghrib_angle, %Date{} = date) do
    solar_time
    |> SolarTime.hour_angle(-1 * maghrib_angle, true)
    |> TimeComponent.new()
    |> TimeComponent.create_utc_datetime(date)
  end

  def adjust(datetime, %CalculationParameter{
        adjustments: %{maghrib: adjustment},
        method_adjustments: %{maghrib: method_adjustment},
        rounding: rounding
      }) do
    adjustment = adjustment |> DateUtils.sum_adjustment(method_adjustment)
    datetime |> DateUtils.rounded_time(adjustment, rounding)
  end
end
