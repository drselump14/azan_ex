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

  def find!(%__MODULE__{
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

  def find!(%__MODULE__{
        sunrise: sunrise,
        date: date,
        calculation_parameter: %CalculationParameter{
          polar_circle_resolution: :unresolved
        }
      }) do
    sunrise |> TimeComponent.new() |> TimeComponent.create_utc_datetime(date)
  end

  def find(sunrise, date, coordinate) do
    {
      :ok,
      %__MODULE__{
        sunrise: sunrise,
        date: date,
        calculation_parameter: %CalculationParameter{},
        coordinate: coordinate
      }
      |> find!()
    }
  end

  def find(
        sunrise,
        date,
        %CalculationParameter{} = calculation_parameter,
        %Coordinate{} = coordinate
      ) do
    {:ok,
     %SunriseTime{
       sunrise: sunrise,
       date: date,
       calculation_parameter: calculation_parameter,
       coordinate: coordinate
     }
     |> SunriseTime.find!()}
  end

  def adjust(datetime, %CalculationParameter{
        adjustments: %{sunrise: adjustment},
        method_adjustments: %{sunrise: method_adjustment},
        rounding: rounding
      }) do
    adjustment = adjustment |> DateUtils.sum_adjustment(method_adjustment)
    datetime |> DateUtils.rounded_time(adjustment, rounding)
  end
end
