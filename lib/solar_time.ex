defmodule SolarTime do
  @moduledoc """
  Documentation for `SolarTime`.
  """

  use TypedStruct

  typedstruct do
    field :date, %Date{}
    field :coordinate, %Coordinate{}
    field :observer, %Coordinate{}
    field :solar, %SolarCoordinate{}
    field :prev_solar, %SolarCoordinate{}
    field :next_solar, %SolarCoordinate{}
    field :approx_transit, float()
    field :transit, float()
    field :sunrise, float()
    field :sunset, float()
  end

  def new(%DateTime{} = datetime, coordinate) do
    datetime |> DateTime.to_date() |> new(coordinate)
  end

  def new(
        %Date{year: year, month: month, day: day},
        %Coordinate{longitude: longitude} = coordinate
      ) do
    julian_day = Astronomical.julian_day(year, month, day)

    solar =
      %SolarCoordinate{
        apparent_side_real_time: apparent_side_real_time,
        right_ascension: right_ascension
      } = SolarCoordinate.init_by_julian_day(julian_day)

    prev_solar = SolarCoordinate.init_by_julian_day(julian_day - 1)
    next_solar = SolarCoordinate.init_by_julian_day(julian_day + 1)

    solar_altitude = -50.0 / 60.0

    m0 = Astronomical.approximate_transit(longitude, apparent_side_real_time, right_ascension)

    %__MODULE__{
      observer: coordinate,
      solar: solar,
      prev_solar: prev_solar,
      next_solar: next_solar,
      approx_transit: m0,
      transit:
        Astronomical.corrected_transit(
          m0,
          longitude,
          apparent_side_real_time,
          right_ascension,
          prev_solar.right_ascension,
          next_solar.right_ascension
        ),
      sunrise:
        AstronomyUtility.corrected_hour_angle(
          m0,
          solar_altitude,
          coordinate,
          false,
          apparent_side_real_time,
          solar,
          prev_solar,
          next_solar
        ),
      sunset:
        AstronomyUtility.corrected_hour_angle(
          m0,
          solar_altitude,
          coordinate,
          true,
          apparent_side_real_time,
          solar,
          prev_solar,
          next_solar
        )
    }
  end

  @spec find_pair_solar_time(Date.t(), Coordinate.t(), CalculationParameter.t()) ::
          {:ok, {SolarTime.t(), SolarTime.t()}}
  def find_pair_solar_time(
        %Date{} = date,
        %Coordinate{} = coordinate,
        %CalculationParameter{polar_circle_resolution: polar_circle_resolution}
      ) do
    tomorrow = date |> Timex.shift(days: 1)

    pair =
      new(date, coordinate)
      |> resolve_safe_time(new(tomorrow, coordinate), polar_circle_resolution, date, coordinate)

    {:ok, pair}
  end

  def hour_angle(
        %__MODULE__{
          approx_transit: approx_transit,
          observer: observer,
          solar:
            %SolarCoordinate{
              apparent_side_real_time: apparent_side_real_time
            } = solar,
          prev_solar: prev_solar,
          next_solar: next_solar
        },
        angle,
        after_transit
      ) do
    AstronomyUtility.corrected_hour_angle(
      approx_transit,
      angle,
      observer,
      after_transit,
      apparent_side_real_time,
      solar,
      prev_solar,
      next_solar
    )
  end

  def afternoon(
        %__MODULE__{
          observer: %Coordinate{latitude: latitude},
          solar: %SolarCoordinate{declination: declination}
        } = solar_time,
        shadow_length
      ) do
    tangent = abs(latitude - declination)
    inverse = shadow_length + Math.tan(Math.deg2rad(tangent))
    angle = (1.0 / inverse) |> Math.atan() |> Math.rad2deg()
    solar_time |> hour_angle(angle, true)
  end

  def resolve_safe_time(
        %SolarTime{sunset: sunset, sunrise: sunrise},
        %SolarTime{sunrise: tomorrow_sunrise},
        polar_circle_resolution,
        date,
        coordinate
      )
      when not is_number(sunrise) or not is_number(sunset) or
             (not is_number(tomorrow_sunrise) and polar_circle_resolution !== :unresolved) do
    %{solar_time: solar_time, tomorrow_solar_time: tomorrow_solar_time} =
      polar_circle_resolution
      |> PolarCircleResolution.polar_circle_resolved_values(date, coordinate)

    {solar_time, tomorrow_solar_time}
  end

  def resolve_safe_time(
        solar_time,
        tomorrow_solar_time,
        _polar_circle_resolution,
        _date,
        _coordinate
      ),
      do: {solar_time, tomorrow_solar_time}
end
