defmodule SolarTime do
  @moduledoc """
  Documentation for `SolarTime`.
  """

  use TypedStruct

  require Logger

  typedstruct do
    field :date, %Date{}
    field :coordinates, %Coordinates{}
    field :observer, %Coordinates{}
    field :solar, %SolarCoordinates{}
    field :prev_solar, %SolarCoordinates{}
    field :next_solar, %SolarCoordinates{}
    field :approx_transit, float()
    field :transit, float()
    field :sunrise, float()
    field :sunset, float()
  end

  def new(
        %Date{year: year, month: month, day: day},
        %Coordinates{longitude: longitude} = coordinates
      ) do
    julian_day = Astronomical.julian_day(year, month + 1, day)

    solar =
      %SolarCoordinates{
        apparent_side_real_time: apparent_side_real_time,
        right_ascension: right_ascension,
        declination: declination
      } = SolarCoordinates.init_by_julian_day(julian_day)

    prev_solar = SolarCoordinates.init_by_julian_day(julian_day - 1)
    next_solar = SolarCoordinates.init_by_julian_day(julian_day + 1)

    solar_altitude = -50.0 / 60.0

    m0 = Astronomical.approximate_transit(longitude, apparent_side_real_time, right_ascension)

    %__MODULE__{
      observer: coordinates,
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
        Astronomical.corrected_hour_angle(
          m0,
          solar_altitude,
          coordinates,
          false,
          apparent_side_real_time,
          right_ascension,
          prev_solar.right_ascension,
          next_solar.right_ascension,
          declination,
          prev_solar.declination,
          next_solar.declination
        ),
      sunset:
        Astronomical.corrected_hour_angle(
          m0,
          solar_altitude,
          coordinates,
          true,
          apparent_side_real_time,
          right_ascension,
          prev_solar.right_ascension,
          next_solar.right_ascension,
          declination,
          prev_solar.declination,
          next_solar.declination
        )
    }
  end

  def hour_angle(
        %__MODULE__{
          approx_transit: approx_transit,
          observer: observer,
          solar: %SolarCoordinates{
            apparent_side_real_time: apparent_side_real_time,
            right_ascension: right_ascension,
            declination: declination
          },
          prev_solar: prev_solar,
          next_solar: next_solar
        },
        angle,
        after_transit
      ) do
    Astronomical.corrected_hour_angle(
      approx_transit,
      angle,
      observer,
      after_transit,
      apparent_side_real_time,
      right_ascension,
      prev_solar.right_ascension,
      next_solar.right_ascension,
      declination,
      prev_solar.declination,
      next_solar.declination
    )
  end

  def afternoon(
        %__MODULE__{
          observer: %Coordinates{latitude: latitude},
          solar: %SolarCoordinates{declination: declination}
        } = solar_time,
        shadow_length: shadow_length
      ) do
    tangent = abs(latitude - declination)
    inverse = shadow_length + Math.tan(Math.deg2rad(tangent))
    angle = (1.0 / inverse) |> Math.atan() |> Math.rad2deg()
    solar_time |> hour_angle(angle, true)
  end
end
