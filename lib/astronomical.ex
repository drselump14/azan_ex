defmodule Astronomical do
  @moduledoc """
  Documentation for `Astronomical`.
  """

  require Logger

  def mean_solar_longitude(julian_century) do
    term_1 = 280.4664567
    term_2 = 36_000.76983 * julian_century
    term_3 = 0.0003032 * julian_century * julian_century
    l_0 = term_1 + term_2 + term_3

    l_0 |> MathUtils.unwind_angle()
  end

  def mean_lunar_longitude(julian_century) do
    term_1 = 218.3165
    term_2 = 481_267.8813 * julian_century
    l_0 = term_1 + term_2

    l_0 |> MathUtils.unwind_angle()
  end

  def ascending_lunar_node_longitude(julian_century) do
    term_1 = 125.04452
    term_2 = -1934.136261 * julian_century
    term_3 = 0.0020708 * julian_century * julian_century
    term_4 = julian_century * julian_century * julian_century / 450_000
    l_0 = term_1 + term_2 + term_3 + term_4

    l_0 |> MathUtils.unwind_angle()
  end

  def mean_solar_anomaly(julian_century) do
    term_1 = 357.52911
    term_2 = 35_999.05029 * julian_century
    term_3 = 0.0001537 * julian_century * julian_century
    m_0 = term_1 + term_2 + term_3

    m_0 |> MathUtils.unwind_angle()
  end

  def solar_equation_of_the_center(julian_century, mean_anomaly) do
    m_rad = mean_anomaly |> Math.deg2rad()

    term_1 =
      Math.sin(m_rad) * (1.914602 - julian_century * (0.004817 + 0.000014 * julian_century))

    term_2 = Math.sin(2 * m_rad) * (0.019993 - 0.000101 * julian_century)
    term_3 = Math.sin(3 * m_rad) * 0.000289
    term_1 + term_2 + term_3
  end

  def apparent_solar_longitude(julian_century, mean_longitude) do
    t = julian_century
    l_0 = mean_longitude
    longitude = l_0 + solar_equation_of_the_center(t, mean_solar_anomaly(t))
    omega = 125.04 - 1934.136 * t
    lambda = longitude - 0.00569 - 0.00478 * (omega |> Math.deg2rad() |> Math.sin())
    lambda |> MathUtils.unwind_angle()
  end

  def mean_obliquity_of_the_ecliptic(julian_century) do
    term1 = 23.439291
    term2 = 0.013004167 * julian_century
    term3 = 0.0000001639 * Math.pow(julian_century, 2)
    term4 = 0.0000005036 * Math.pow(julian_century, 3)
    term1 - term2 - term3 + term4
  end

  def apparent_obliquity_of_the_ecliptic(julian_century, mean_obliquity_of_the_eliptic) do
    t = julian_century
    epsilon_0 = mean_obliquity_of_the_eliptic

    o = 125.04 - 1934.136 * t
    epsilon_0 + 0.00256 * (o |> Math.deg2rad() |> Math.cos())
  end

  def mean_sidereal_time(julian_century) do
    t = julian_century
    jd = t * 36525 + 2_451_545.0
    term1 = 280.46061837
    term2 = 360.98564736629 * (jd - 2_451_545)
    term3 = 0.000387933 * Math.pow(t, 2)
    term4 = Math.pow(t, 3) / 38_710_000
    (term1 + term2 + term3 - term4) |> MathUtils.unwind_angle()
  end

  def nutation_in_longitude(solar_longitude, lunar_longitude, ascending_node) do
    l_0 = solar_longitude
    l_p = lunar_longitude
    omega = ascending_node
    term1 = omega |> Math.deg2rad() |> Math.sin() |> Kernel.*(-17.2 / 3600)
    term2 = l_0 |> Math.deg2rad() |> Kernel.*(2) |> Math.sin() |> Kernel.*(1.32 / 3600)
    term3 = l_p |> Math.deg2rad() |> Kernel.*(2) |> Math.sin() |> Kernel.*(0.23 / 3600)
    term4 = omega |> Math.deg2rad() |> Kernel.*(2) |> Math.sin() |> Kernel.*(0.21 / 3600)
    term1 - term2 - term3 + term4
  end

  def nutation_in_obliquity(solar_longitude, lunar_longitude, ascending_node) do
    l_0 = solar_longitude
    l_p = lunar_longitude
    omega = ascending_node
    term1 = omega |> Math.deg2rad() |> Math.cos() |> Kernel.*(9.2 / 3600)
    term2 = l_0 |> Math.deg2rad() |> Kernel.*(2) |> Math.cos() |> Kernel.*(0.57 / 3600)
    term3 = l_p |> Math.deg2rad() |> Kernel.*(2) |> Math.cos() |> Kernel.*(0.1 / 3600)
    term4 = omega |> Math.deg2rad() |> Kernel.*(2) |> Math.cos() |> Kernel.*(0.09 / 3600)
    term1 + term2 + term3 - term4
  end

  def altitude_of_celestial_body(observer_latitude, declination, local_hour_angle) do
    phi = observer_latitude
    delta = declination
    h = local_hour_angle

    term1 = MathUtils.sin_deg(phi) * MathUtils.sin_deg(delta)
    term2 = MathUtils.cos_deg(phi) * MathUtils.cos_deg(delta) * MathUtils.cos_deg(h)

    (term1 + term2) |> Math.asin() |> Math.rad2deg()
  end

  def approximate_transit(longitude, sidereal_time, right_ascension) do
    l = longitude
    theta0 = sidereal_time
    a2 = right_ascension
    l_w = l * -1
    (a2 + l_w - theta0) |> Kernel./(360) |> MathUtils.normalize_to_scale(1)
  end

  def corrected_transit(
        approximate_transit,
        longitude,
        sidereal_time,
        right_ascension,
        previous_right_ascension,
        next_right_ascension
      ) do
    m0 = approximate_transit
    l = longitude
    theta0 = sidereal_time
    a2 = right_ascension
    a1 = previous_right_ascension
    a3 = next_right_ascension
    l_w = l * -1
    theta = (theta0 + 360.985647 * m0) |> MathUtils.unwind_angle()
    a = Astronomical.interpolate_angles(a2, a1, a3, m0) |> MathUtils.unwind_angle()
    h = (theta - l_w - a) |> MathUtils.quadrant_shift_angle()
    dm = h / -360
    (m0 + dm) * 24
  end

  def corrected_hour_angle(
        approximate_transit,
        angle,
        %Coordinates{latitude: latitude, longitude: longitude},
        after_transit,
        sidereal_time,
        right_ascension,
        previous_right_ascension,
        next_right_ascension,
        declination,
        previous_declination,
        next_declination
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

  def interpolate(y2, y1, y3, n) do
    a = y2 - y1
    b = y3 - y2
    c = b - a
    y2 + n * (a + b + c * n) / 2
  end

  def interpolate_angles(y2, y1, y3, n) do
    a = (y2 - y1) |> MathUtils.unwind_angle()
    b = (y3 - y2) |> MathUtils.unwind_angle()
    c = b - a
    y2 + n / 2 * (a + b + n * c)
  end

  def julian_century(julian_day) do
    (julian_day - 2_451_545.0) / 36_525
  end

  def julian_day(year, month, day, hours) do
    y = if month > 2, do: year, else: year - 1
    m = if month > 2, do: month, else: month + 12
    d = day + hours / 24

    a = (y / 100) |> trunc()
    b = (2 - a + trunc(a / 4)) |> trunc()

    i0 = trunc(365.25 * (y + 4716))
    i1 = trunc(30.6001 * (m + 1))

    i0 + i1 + d + b - 1524.5
  end

  def julian_day(year, month, day) do
    julian_day(year, month, day, 0)
  end

  def is_leap_year(year) when rem(year, 4) !== 0, do: false
  def is_leap_year(year) when rem(year, 100) == 0 and rem(year, 400) !== 0, do: false
  def is_leap_year(_year), do: true
end
