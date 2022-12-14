defmodule Azan.SunsetTime do
  @moduledoc """
  Documentation for `SunsetTime`.
  """
  alias Azan.{
    CalculationParameter,
    Coordinate,
    DateUtils,
    PolarCircleResolution,
    SolarTime,
    TimeComponent
  }

  use TypedStruct

  typedstruct do
    field :sunset, number()
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
    %PolarCircleResolution{solar_time: %SolarTime{sunset: new_sunset}} =
      polar_circle_resolution
      |> PolarCircleResolution.polar_circle_resolved_values(date, coordinate)

    TimeComponent.new(new_sunset)
    |> TimeComponent.create_utc_datetime(date)
  end

  def find!(%__MODULE__{
        sunset: sunset,
        date: date,
        calculation_parameter: %CalculationParameter{
          polar_circle_resolution: :unresolved
        }
      }) do
    TimeComponent.new(sunset) |> TimeComponent.create_utc_datetime(date)
  end

  def find(
        sunset,
        date,
        %CalculationParameter{} = calculation_parameter,
        %Coordinate{} = coordinate
      ) do
    {:ok,
     %__MODULE__{
       sunset: sunset,
       date: date,
       calculation_parameter: calculation_parameter,
       coordinate: coordinate
     }
     |> __MODULE__.find!()}
  end

  def adjust(datetime, %CalculationParameter{
        rounding: rounding
      }) do
    datetime |> DateUtils.rounded_minute(rounding)
  end
end
