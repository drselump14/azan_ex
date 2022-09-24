defmodule SunriseTime do
  @moduledoc """
  Documentation for `SunriseTime`.
  """

  use TypedStruct

  typedstruct do
    field :sunrise, number()
    field :date, Date.t()
    field :calculation_parameter, CalculationParameter.t()
    field :coordinate, Coordinate.t()
  end

  def find(%__MODULE__{
        date: date,
        coordinate: coordinate,
        calculation_parameter: %CalculationParameter{
          polar_circle_resolution: polar_circle_resolution
        }
      }) do
    %PolarCircleResolution{solar_time: %SolarTime{sunrise: new_sunrise}} =
      polar_circle_resolution
      |> PolarCircleResolution.polar_circle_resolved_values(date, coordinate)

    TimeComponent.new(new_sunrise)
    |> TimeComponent.create_utc_datetime(date)
  end

  def find(%__MODULE__{
        sunrise: sunrise,
        date: date,
        calculation_parameter: %CalculationParameter{
          polar_circle_resolution: :unresolved
        }
      }) do
    TimeComponent.new(sunrise) |> TimeComponent.create_utc_datetime(date)
  end
end
