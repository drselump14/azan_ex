defmodule Astronomical do
  @moduledoc """
  Documentation for `Astronomical`.
  """

  def mean_solar_longitude(julian_century) do
    term_1 = 280.4664567
    term_2 = 36000.76983 * julian_century
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
    term_2 = 35999.05029 * julian_century
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
end
