defmodule Azan.Astronomical do
  @moduledoc """
  Documentation for `Astronomical`.
  """
  @northern_offset 10

  alias Azan.{
    DateUtils,
    MathUtils
  }

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
    jd = t * 36_525 + 2_451_545.0
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
    a = __MODULE__.interpolate_angles(a2, a1, a3, m0) |> MathUtils.unwind_angle()
    h = (theta - l_w - a) |> MathUtils.quadrant_shift_angle()
    dm = h / -360
    (m0 + dm) * 24
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

  @spec southern_offset(pos_integer()) :: pos_integer()
  def southern_offset(year) do
    if year |> Timex.is_leap?(), do: 173, else: 172
  end

  @spec days_since_solstice(pos_integer(), pos_integer(), float()) :: integer()
  def days_since_solstice(day_of_year, year, latitude) when latitude >= 0 do
    days_since_solstice = day_of_year + @northern_offset
    days_in_year = year |> DateUtils.days_in_year()

    case days_since_solstice >= days_in_year do
      true -> days_since_solstice - days_in_year
      false -> days_since_solstice
    end
  end

  def days_since_solstice(day_of_year, year, latitude) when latitude < 0 do
    southern_offset = year |> __MODULE__.southern_offset()
    days_since_solstice = day_of_year - southern_offset
    days_in_year = year |> DateUtils.days_in_year()

    case days_since_solstice < 0 do
      true -> days_since_solstice + days_in_year
      false -> days_since_solstice
    end
  end

  def season_adjusted_morning_twilight(latitude, day_of_year, year, %DateTime{} = sunrise) do
    a = 75 + 28.65 / 55.0 * abs(latitude)
    b = 75 + 19.44 / 55.0 * abs(latitude)
    c = 75 + 32.74 / 55.0 * abs(latitude)
    d = 75 + 48.1 / 55.0 * abs(latitude)

    adjustment =
      case day_of_year |> __MODULE__.days_since_solstice(year, latitude) do
        dyy when dyy < 91 -> a + (b - a) / 91.0 * dyy
        dyy when dyy < 137 -> b + (c - b) / 46.0 * (dyy - 91)
        dyy when dyy < 183 -> c + (d - c) / 46.0 * (dyy - 137)
        dyy when dyy < 229 -> d + (c - d) / 46.0 * (dyy - 183)
        dyy when dyy < 275 -> c + (b - c) / 46.0 * (dyy - 229)
        dyy -> b + (a - b) / 91.0 * (dyy - 275)
      end

    sunrise |> Timex.shift(seconds: adjustment |> Kernel.*(-60) |> round())
  end

  def season_adjusted_evening_twilight(latitude, day_of_year, year, sunset, shafaq) do
    %{a: a, b: b, c: c, d: d} = latitude |> abcd_seasoned_adjusted_evening_twilight(shafaq)

    adjustment =
      case day_of_year |> __MODULE__.days_since_solstice(year, latitude) do
        dyy when dyy < 91 -> a + (b - a) / 91.0 * dyy
        dyy when dyy < 137 -> b + (c - b) / 46.0 * (dyy - 91)
        dyy when dyy < 183 -> c + (d - c) / 46.0 * (dyy - 137)
        dyy when dyy < 229 -> d + (c - d) / 46.0 * (dyy - 183)
        dyy when dyy < 275 -> c + (b - c) / 46.0 * (dyy - 229)
        dyy -> b + (a - b) / 91.0 * (dyy - 275)
      end

    sunset |> DateUtils.shift_by_seconds(adjustment |> Kernel.*(60) |> round())
  end

  defp abcd_seasoned_adjusted_evening_twilight(latitude, :ahmer) do
    abs_latitude = latitude |> abs()

    %{
      a: 62 + 17.4 / 55.0 * abs_latitude,
      b: 62 - 7.16 / 55.0 * abs_latitude,
      c: 62 + 5.12 / 55.0 * abs_latitude,
      d: 62 + 19.44 / 55.0 * abs_latitude
    }
  end

  defp abcd_seasoned_adjusted_evening_twilight(latitude, :abyad) do
    abs_latitude = latitude |> abs()

    %{
      a: 75 + 25.6 / 55.0 * abs_latitude,
      b: 75 + 7.16 / 55.0 * abs_latitude,
      c: 75 + 36.84 / 55.0 * abs_latitude,
      d: 75 + 81.84 / 55.0 * abs_latitude
    }
  end

  defp abcd_seasoned_adjusted_evening_twilight(latitude, _) do
    abs_latitude = latitude |> abs()

    %{
      a: 75 + 25.6 / 55.0 * abs_latitude,
      b: 75 + 2.05 / 55.0 * abs_latitude,
      c: 75 - 9.21 / 55.0 * abs_latitude,
      d: 75 + 6.14 / 55.0 * abs_latitude
    }
  end

  def julian_century(julian_day) do
    (julian_day - 2_451_545.0) / 36_525
  end

  def julian_day(year, month, day, hours \\ 0) do
    y = if(month > 2, do: year, else: year - 1) |> trunc()
    m = if(month > 2, do: month, else: month + 12) |> trunc()
    d = day + hours / 24

    a = (y / 100) |> trunc()
    b = (2 - a + trunc(a / 4)) |> trunc()

    i0 = trunc(365.25 * (y + 4716))
    i1 = trunc(30.6001 * (m + 1))

    i0 + i1 + d + b - 1524.5
  end
end
