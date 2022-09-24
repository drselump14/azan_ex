defmodule SafeFajr do
  @moduledoc """
  Documentation for `SafeFajr`.
  """

  use TypedStruct

  typedstruct do
    field :calculation_parameter, CalculationParameter.t()
    field :sunrise_time, DateTime.t()
    field :night, number()
    field :latitude, number()
    field :date, Date.t()
  end

  def find_time(%__MODULE__{
        calculation_parameter: %CalculationParameter{method: :moonsighting_committee},
        sunrise_time: sunrise_time,
        latitude: latitude,
        date: %Date{year: year} = date
      }) do
    Astronomical.season_adjusted_morning_twilight(
      latitude,
      date |> DateUtils.day_of_year(),
      year,
      sunrise_time
    )
  end

  def find_time(%__MODULE__{
        calculation_parameter: calculation_parameter,
        sunrise_time: sunrise_time,
        night: night
      }) do
    %{isha: portion} = calculation_parameter |> CalculationParameter.night_portions()
    night_fraction = night * portion
    sunrise_time |> DateUtils.shift_by_seconds(-1 * night_fraction)
  end
end
