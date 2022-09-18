defmodule AstronomicalTest do
  @moduledoc """
  Documentation for `AstronomicalTest`.
  """

  use Azan.TestCase

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

  test "julian_day" do
    assert Astronomical.julian_day(2022, 9, 18) == 2_459_840.5
  end

  test "is_leap_year" do
    assert Astronomical.is_leap_year(2016) == true
    assert Astronomical.is_leap_year(2000) == true
    assert Astronomical.is_leap_year(1300) == false
  end

  test "julian_century" do
    assert Astronomical.julian_century(2_451_545) == 0.0
  end
end
