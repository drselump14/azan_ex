defmodule AstronomicalTest do
  @moduledoc """
  Documentation for `AstronomicalTest`.
  """

  use Azan.TestCase

  require Logger

  test "calculate solar coordinate values" do
    jd = Astronomical.julian_day(1992, 10, 13)

    %SolarCoordinates{declination: delta, right_ascension: right_ascension} =
      jd |> SolarCoordinates.init_by_julian_day()

    t = jd |> Astronomical.julian_century()
    l_0 = t |> Astronomical.mean_solar_longitude()
    e_0 = t |> Astronomical.mean_obliquity_of_the_ecliptic()
    e_app = t |> Astronomical.apparent_obliquity_of_the_ecliptic(e_0)
    m = t |> Astronomical.mean_solar_anomaly()
    c = t |> Astronomical.solar_equation_of_the_center(m)
    lambda = t |> Astronomical.apparent_solar_longitude(l_0)
    alpha = right_ascension |> MathUtils.unwind_angle()

    assert_to_be_close_to(t, -0.072183436, 9)
    assert_to_be_close_to(l_0, 201.8072, 4)
    assert_to_be_close_to(e_0, 23.44023, 4)
    assert_to_be_close_to(e_app, 23.43999, 4)
    assert_to_be_close_to(m, 278.99397, 4)
    assert_to_be_close_to(c, -1.89732, 4)
    assert_to_be_close_to(lambda, 199.90895, 3)
    assert_to_be_close_to(delta, -7.78507, 4)
    assert_to_be_close_to(alpha, 198.38083, 4)
  end

  test "calculate solar coordinate value 2" do
    jd = Astronomical.julian_day(1987, 4, 10)

    %SolarCoordinates{apparent_side_real_time: theta_app} =
      jd |> SolarCoordinates.init_by_julian_day()

    t = jd |> Astronomical.julian_century()

    theta_0 = t |> Astronomical.mean_sidereal_time()
    omega = t |> Astronomical.ascending_lunar_node_longitude()
    e_0 = t |> Astronomical.mean_obliquity_of_the_ecliptic()
    l_0 = t |> Astronomical.mean_solar_longitude()
    l_p = t |> Astro.Lunar.mean_lunar_longitude()
    dpsi = l_0 |> Astronomical.nutation_in_longitude(l_p, omega)
    d_epsilon = l_0 |> Astronomical.nutation_in_obliquity(l_p, omega)
    e = e_0 + d_epsilon

    assert_to_be_close_to(theta_0, 197.693195, 5)
    assert_to_be_close_to(theta_app, 197.6922295833, 2)

    assert_to_be_close_to(omega, 11.2531, 3)
    assert_to_be_close_to(dpsi, -0.0010522, 3)
    assert_to_be_close_to(d_epsilon, 0.0026230556, 4)
    assert_to_be_close_to(e_0, 23.4409463889, 5)
    assert_to_be_close_to(e, 23.4435694444, 4)
  end

  test "calculate the altitude of celestial body" do
    phi = 38 + 55 / 60 + 17.0 / 3600
    delta = -6 - 43 / 60 - 11.61 / 3600
    h = 64.352133
    altitude = phi |> Astronomical.altitude_of_celestial_body(delta, h)

    assert_to_be_close_to(altitude, 15.1249, 3)
  end

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
    coordinates = %Coordinates{latitude: 42.3333, longitude: longitude}

    rise =
      Astronomical.corrected_hour_angle(
        m0,
        -0.5667,
        coordinates,
        false,
        theta,
        alpha2,
        alpha1,
        alpha3,
        delta2,
        delta1,
        delta3
      ) / 24

    assert_to_be_close_to(rise, 0.51766, 4)
  end

  test "calculate solar time values" do
    coordinates = %Coordinates{latitude: 35 + 47 / 60, longitude: -78 - 39 / 60}

    solar =
      %SolarTime{transit: transit, sunrise: sunrise, sunset: sunset} =
      SolarTime.new(Date.new!(2015, 6, 12), coordinates)

    twilight_start = solar |> SolarTime.hour_angle(-6, false)
    twilight_end = solar |> SolarTime.hour_angle(-6, true)

    assert assert_time_string(TimeComponent.new(twilight_start), "9:38")
    assert assert_time_string(TimeComponent.new(sunrise), "10:08")
    assert assert_time_string(TimeComponent.new(transit), "17:20")
    assert assert_time_string(TimeComponent.new(sunset), "24:32")
    assert assert_time_string(TimeComponent.new(twilight_end), "25:02")
  end

  test "verify the correct calendar date is being used for calculations" do
    coordinates = %Coordinates{latitude: 20 + 7 / 60, longitude: -155 - 34 / 60}
    day1solar = SolarTime.new(Date.new!(2015, 3, 2), coordinates)
    day2solar = SolarTime.new(Date.new!(2015, 3, 3), coordinates)

    day1 = day1solar.sunrise
    day2 = day2solar.sunrise

    assert assert_time_string(TimeComponent.new(day1), "16:15")
    assert assert_time_string(TimeComponent.new(day2), "16:14")
  end

  test "interpolate a value given previous and next values along with an interpolation factor" do
    interpolated_value =
      Astronomical.interpolate(
        0.877366,
        0.884226,
        0.870531,
        4.35 / 24
      )

    assert_to_be_close_to(interpolated_value, 0.876125, 5)

    i1 = Astronomical.interpolate(1, -1, 3, 0.6)
    assert_to_be_close_to(i1, 2.2, 5)

    i2 = Astronomical.interpolate_angles(1, -1, 3, 0.6)
    assert_to_be_close_to(i2, 2.2, 5)

    i3 = Astronomical.interpolate_angles(1, 359, 3, 0.6)
    assert_to_be_close_to(i3, 2.2, 5)
  end

  test "julian_day" do
    assert Astronomical.julian_day(2022, 9, 18) == 2_459_840.5

    assert Astronomical.julian_day(2010, 1, 2) == 2_455_198.5
    assert Astronomical.julian_day(2011, 2, 4) == 2_455_596.5
    assert Astronomical.julian_day(2012, 3, 6) == 2_455_992.5
    assert Astronomical.julian_day(2013, 4, 8) == 2_456_390.5
    assert Astronomical.julian_day(2014, 5, 10) == 2_456_787.5
    assert Astronomical.julian_day(2015, 6, 12) == 2_457_185.5
    assert Astronomical.julian_day(2016, 7, 14) == 2_457_583.5
    assert Astronomical.julian_day(2017, 8, 16) == 2_457_981.5
    assert Astronomical.julian_day(2018, 9, 18) == 2_458_379.5
    assert Astronomical.julian_day(2019, 10, 20) == 2_458_776.5
    assert Astronomical.julian_day(2020, 11, 22) == 2_459_175.5
    assert Astronomical.julian_day(2021, 12, 24) == 2_459_572.5
  end

  test "calculate the days since the winter of summer solstice" do
    assert DateUtils.day_of_year(2016, 1, 1) |> Astronomical.days_since_solstice(2016, 1) == 11
    assert DateUtils.day_of_year(2015, 12, 31) |> Astronomical.days_since_solstice(2015, 1) == 10
    assert DateUtils.day_of_year(2016, 12, 31) |> Astronomical.days_since_solstice(2016, 1) == 10
    assert DateUtils.day_of_year(2016, 12, 21) |> Astronomical.days_since_solstice(2016, 1) == 0
    assert DateUtils.day_of_year(2016, 12, 22) |> Astronomical.days_since_solstice(2016, 1) == 1
    assert DateUtils.day_of_year(2016, 3, 1) |> Astronomical.days_since_solstice(2016, 1) == 71
    assert DateUtils.day_of_year(2015, 3, 1) |> Astronomical.days_since_solstice(2015, 1) == 70
    assert DateUtils.day_of_year(2016, 12, 20) |> Astronomical.days_since_solstice(2016, 1) == 365
    assert DateUtils.day_of_year(2015, 12, 20) |> Astronomical.days_since_solstice(2015, 1) == 364
  end

  test "julian_century" do
    assert Astronomical.julian_century(2_451_545) == 0.0
  end
end
