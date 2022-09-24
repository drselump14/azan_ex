defmodule SafeIsha do
  @moduledoc """
  Documentation for `SafeIsha`.
  """

  use TypedStruct

  typedstruct do
    field :calculation_parameter, CalculationParameter.t()
    field :night, number()
    field :latitude, number()
    field :date, Date.t()
    field :sunset_time, DateTime.t()
  end

  def find(%__MODULE__{
        calculation_parameter: %CalculationParameter{
          method: :moonsighting_committee,
          shafaq: shafaq
        },
        latitude: latitude,
        date: %Date{year: year} = date,
        sunset_time: sunset_time
      }) do
    Astronomical.season_adjusted_evening_twilight(
      latitude,
      date |> DateUtils.day_of_year(),
      year,
      sunset_time,
      shafaq
    )
  end

  def find(%__MODULE__{
        calculation_parameter: calculation_parameter,
        night: night,
        sunset_time: sunset_time
      }) do
    %{isha: portion} = calculation_parameter |> CalculationParameter.night_portions()
    night_fraction = night * portion
    sunset_time |> DateUtils.shift_by_seconds(night_fraction)
  end
end
