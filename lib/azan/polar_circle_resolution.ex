defmodule Azan.PolarCircleResolution do
  @moduledoc """
  Documentation for `PolarCircleResolution`.
  """

  @latitude_variation_step 0.5
  @unsafe_location 65

  alias Azan.{
    Coordinate,
    DateUtils,
    MathUtils,
    SolarTime
  }

  require Logger

  use TypedStruct

  typedstruct do
    field :date, Date.t()
    field :tomorrow, Date.t()
    field :coordinate, Coordinate.t()
    field :solar_time, SolarTime.t()
    field :tomorrow_solar_time, SolarTime.t()
  end

  def valid_solar_time?(%SolarTime{sunrise: sunrise, sunset: sunset})
      when is_number(sunrise) and is_number(sunset),
      do: true

  def valid_solar_time?(%SolarTime{}), do: false

  def aqrab_yaum_resolver(
        coordinate,
        date,
        days_added \\ 1,
        direction \\ 1
      )

  def aqrab_yaum_resolver(_coordinate, _date, days_added, _direction)
      when days_added > ceil(365 / 2),
      do: nil

  def aqrab_yaum_resolver(
        %Coordinate{} = coordinate,
        %Date{} = date,
        days_added,
        direction
      ) do
    with {:ok, epoch_date} <-
           date |> Timex.shift(days: days_added * direction) |> DateUtils.wrap_timex_error(),
         {:ok, tomorrow} <- epoch_date |> Timex.shift(days: 1) |> DateUtils.wrap_timex_error() do
      solar_time = SolarTime.new(epoch_date, coordinate)
      tomorrow_solar_time = SolarTime.new(tomorrow, coordinate)

      case valid_solar_time?(solar_time) && valid_solar_time?(tomorrow_solar_time) do
        true ->
          %__MODULE__{
            date: date,
            tomorrow: tomorrow,
            coordinate: coordinate,
            solar_time: solar_time,
            tomorrow_solar_time: tomorrow_solar_time
          }

        _ ->
          days_offset = if direction > 0, do: 0, else: 1
          days_added = days_added + days_offset

          aqrab_yaum_resolver(coordinate, date, days_added, -direction)
      end
    else
      {:error, reason} -> raise reason
    end
  end

  def aqrab_balad_resolver(%Coordinate{} = coordinate, %Date{} = date, latitude) do
    new_coordinate = %{coordinate | latitude: latitude}
    solar_time = date |> SolarTime.new(new_coordinate)
    tomorrow = date |> Timex.shift(days: 1)
    tomorrow_solar_time = tomorrow |> SolarTime.new(new_coordinate)

    case valid_solar_time?(solar_time) && valid_solar_time?(tomorrow_solar_time) do
      true ->
        %__MODULE__{
          date: date,
          tomorrow: tomorrow,
          coordinate: new_coordinate,
          solar_time: solar_time,
          tomorrow_solar_time: tomorrow_solar_time
        }

      false ->
        if abs(latitude) < @unsafe_location,
          do: nil,
          else:
            aqrab_balad_resolver(
              coordinate,
              date,
              latitude - MathUtils.sign(latitude) * @latitude_variation_step
            )
    end
  end

  def polar_circle_resolved_values(:aqrab_yaum, %Date{} = date, %Coordinate{} = coordinate) do
    resolved = coordinate |> aqrab_yaum_resolver(date)
    default = default_polar_circle_resolve_values(date, coordinate)

    resolved || default
  end

  def polar_circle_resolved_values(
        :aqrab_balad,
        %Date{} = date,
        %Coordinate{latitude: latitude} = coordinate
      ) do
    coordinate
    |> aqrab_balad_resolver(date, latitude - MathUtils.sign(latitude) * @latitude_variation_step) ||
      default_polar_circle_resolve_values(date, coordinate)
  end

  def polar_circle_resolved_values(:unresolved, %Date{} = date, %Coordinate{} = coordinate) do
    tomorrow = date |> Timex.shift(days: 1)

    %__MODULE__{
      date: date,
      tomorrow: tomorrow,
      coordinate: coordinate,
      solar_time: SolarTime.new(date, coordinate),
      tomorrow_solar_time: SolarTime.new(tomorrow, coordinate)
    }
  end

  def default_polar_circle_resolve_values(date, coordinate) do
    :unresolved |> polar_circle_resolved_values(date, coordinate)
  end
end
