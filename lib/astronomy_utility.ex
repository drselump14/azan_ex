defmodule AstronomyUtility do
  @moduledoc """
  Documentation for `AstronomyUtility`.
  """

  def corrected_hour_angle(
        approximate_transit,
        angle,
        %Coordinates{latitude: latitude, longitude: longitude},
        after_transit,
        sidereal_time,
        %SolarCoordinates{right_ascension: right_ascension, declination: declination} = _solar,
        %SolarCoordinates{
          right_ascension: previous_right_ascension,
          declination: previous_declination
        } = _prev_solar,
        %SolarCoordinates{right_ascension: next_right_ascension, declination: next_declination} =
          _next_solar
      ) do
    m0 = approximate_transit
    h0 = angle
    theta0 = sidereal_time
    a2 = right_ascension
    a1 = previous_right_ascension
    a3 = next_right_ascension
    d2 = declination
    d1 = previous_declination
    d3 = next_declination

    lw = -1 * longitude
    term1 = MathUtils.sin_deg(h0) - MathUtils.sin_deg(latitude) * MathUtils.sin_deg(d2)
    term2 = MathUtils.cos_deg(latitude) * MathUtils.cos_deg(d2)

    h0_capital = (term1 / term2) |> :math.acos() |> Math.rad2deg()

    m = if after_transit, do: m0 + h0_capital / 360, else: m0 - h0_capital / 360
    theta = (theta0 + 360.985647 * m) |> MathUtils.unwind_angle()
    a = Astronomical.interpolate_angles(a2, a1, a3, m) |> MathUtils.unwind_angle()

    delta = Astronomical.interpolate(d2, d1, d3, m)
    h_capital = theta - lw - a

    h =
      Astronomical.altitude_of_celestial_body(
        latitude,
        delta,
        h_capital
      )

    term3 = h - h0

    term4 =
      360 * MathUtils.cos_deg(delta) * MathUtils.cos_deg(latitude) * MathUtils.sin_deg(h_capital)

    dm = term3 / term4
    (m + dm) * 24
  end
end
