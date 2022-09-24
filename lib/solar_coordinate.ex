defmodule SolarCoordinate do
  @moduledoc """
  Documentation for `SolarCoordinate`.
  """

  use TypedStruct

  typedstruct do
    field :declination, :float
    field :right_ascension, :float
    field :apparent_side_real_time, :float
  end

  def init_by_julian_day(julian_day) do
    t = julian_day |> Astronomical.julian_century()
    l_0 = t |> Astronomical.mean_solar_longitude()
    l_p = t |> Astro.Lunar.mean_lunar_longitude()
    omega = t |> Astronomical.ascending_lunar_node_longitude()
    lambda = t |> Astronomical.apparent_solar_longitude(l_0) |> Math.deg2rad()
    theta_0 = t |> Astronomical.mean_sidereal_time()
    dpsi = l_0 |> Astronomical.nutation_in_longitude(l_p, omega)
    d_epsilon = l_0 |> Astronomical.nutation_in_obliquity(l_p, omega)
    epsilon_0 = t |> Astronomical.mean_obliquity_of_the_ecliptic()

    epsilon_apparent =
      t |> Astronomical.apparent_obliquity_of_the_ecliptic(epsilon_0) |> Math.deg2rad()

    %__MODULE__{
      declination:
        (Math.sin(epsilon_apparent) * Math.sin(lambda)) |> Math.asin() |> Math.rad2deg(),
      right_ascension:
        Math.atan2(Math.cos(epsilon_apparent) * Math.sin(lambda), Math.cos(lambda))
        |> Math.rad2deg()
        |> MathUtils.unwind_angle(),
      apparent_side_real_time: theta_0 + dpsi * Math.cos(epsilon_0 + d_epsilon)
    }
  end
end
