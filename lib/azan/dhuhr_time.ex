defmodule Azan.DhuhrTime do
  @moduledoc """
  Documentation for `DhuhrTime`.
  """

  use TypedStruct

  alias Azan.{
    CalculationParameter,
    Coordinate,
    DateUtils,
    PolarCircleResolution,
    SolarTime,
    TimeComponent
  }

  typedstruct do
    field :transit, number()
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
    %PolarCircleResolution{solar_time: %SolarTime{transit: new_transit}} =
      polar_circle_resolution
      |> PolarCircleResolution.polar_circle_resolved_values(date, coordinate)

    TimeComponent.new(new_transit)
    |> TimeComponent.create_utc_datetime(date)
  end

  def find!(%__MODULE__{
        transit: transit,
        date: date,
        calculation_parameter: %CalculationParameter{
          polar_circle_resolution: :unresolved
        }
      }) do
    TimeComponent.new(transit) |> TimeComponent.create_utc_datetime(date)
  end

  def find(
        transit,
        date,
        %CalculationParameter{} = calculation_parameter,
        %Coordinate{} = coordinate
      ) do
    {:ok,
     %__MODULE__{
       transit: transit,
       date: date,
       calculation_parameter: calculation_parameter,
       coordinate: coordinate
     }
     |> __MODULE__.find!()}
  end

  def adjust(datetime, %CalculationParameter{
        adjustments: %{dhuhr: adjustment},
        method_adjustments: %{dhuhr: method_adjustment},
        rounding: rounding
      }) do
    adjustment = adjustment |> DateUtils.sum_adjustment(method_adjustment)
    datetime |> DateUtils.rounded_time(adjustment, rounding)
  end
end
