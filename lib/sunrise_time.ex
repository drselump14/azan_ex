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
        sunrise: sunrise,
        date: date,
        coordinate: coordinate,
        calculation_parameter: %CalculationParameter{
          polar_circle_resolution: polar_circle_resolution
        }
      })
      when polar_circle_resolution !== :unresolved and not is_number(sunrise) do
    find_safe_time(polar_circle_resolution, date, coordinate)
  end

  def find!(%__MODULE__{
        sunrise: sunrise,
        date: date,
        coordinate: coordinate,
        calculation_parameter: %CalculationParameter{
          polar_circle_resolution: polar_circle_resolution
        }
      })
      when polar_circle_resolution !== :unresolved and is_number(sunrise) do
    case find_naive_time!(sunrise, date) do
      {:error, _} ->
        find_safe_time(polar_circle_resolution, date, coordinate)

      naive_time ->
        naive_time
    end
  end

  def find!(%__MODULE__{
        sunrise: sunrise,
        date: date,
        calculation_parameter: %CalculationParameter{
          polar_circle_resolution: :unresolved
        }
      }) do
    sunrise |> find_naive_time!(date)
  end

  def find(sunrise, date, coordinate) do
    find(sunrise, date, %CalculationParameter{}, coordinate)
  end

  def find(
        sunrise,
        date,
        %CalculationParameter{} = calculation_parameter,
        %Coordinate{} = coordinate
      ) do
    case %__MODULE__{
           sunrise: sunrise,
           date: date,
           calculation_parameter: calculation_parameter,
           coordinate: coordinate
         }
         |> find!() do
      {:error, reason} ->
        {:error, reason}

      sunrise_time ->
        {:ok, sunrise_time}
    end
  end

  def find_naive_time!(sunrise, date) do
    sunrise |> TimeComponent.new() |> TimeComponent.create_utc_datetime(date)
  end

  def find_naive_time(sunrise, date) do
    case find_naive_time!(sunrise, date) do
      {:error, reason} ->
        {:error, reason}

      naive_time ->
        {:ok, naive_time}
    end
  end

  def find_safe_time(polar_circle_resolution, date, coordinate) do
    %PolarCircleResolution{solar_time: %SolarTime{sunrise: new_sunrise}} =
      polar_circle_resolution
      |> PolarCircleResolution.polar_circle_resolved_values(date, coordinate)

    TimeComponent.new(new_sunrise)
    |> TimeComponent.create_utc_datetime(date)
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
