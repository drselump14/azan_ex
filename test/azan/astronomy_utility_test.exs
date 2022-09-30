defmodule Azan.AstronomyUtilityTest do
  @moduledoc """
  Documentation for `AstronomyUtilityTest`.
  """

  alias Azan.{
    Astronomical,
    AstronomyUtility,
    Coordinate,
    SolarCoordinate
  }

  use Azan.TestCase

  test "calculate the transit and hour angle" do
    longitude = -71.0833
    theta = 177.74208
    alpha1 = 40.68021
    alpha2 = 41.73129
    alpha3 = 42.78204
    m0 = longitude |> Astronomical.approximate_transit(theta, alpha2)

    assert_to_be_close_to(m0, 0.81965, 3)

    transit = Astronomical.corrected_transit(m0, longitude, theta, alpha2, alpha1, alpha3) / 24

    assert_to_be_close_to(transit, 0.8198, 4)

    delta1 = 18.04761
    delta2 = 18.44092
    delta3 = 18.82742
    coordinate = %Coordinate{latitude: 42.3333, longitude: longitude}

    solar = %SolarCoordinate{declination: delta2, right_ascension: alpha2}
    prev_solar = %SolarCoordinate{declination: delta1, right_ascension: alpha1}
    next_solar = %SolarCoordinate{declination: delta3, right_ascension: alpha3}

    rise =
      AstronomyUtility.corrected_hour_angle(
        m0,
        -0.5667,
        coordinate,
        false,
        theta,
        solar,
        prev_solar,
        next_solar
      ) / 24

    assert_to_be_close_to(rise, 0.51766, 4)
  end
end
