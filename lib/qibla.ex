defmodule Qibla do
  @moduledoc """
  Documentation for `Qibla`.
  """

  require Logger

  def find(%Coordinate{latitude: latitude, longitude: longitude}) do
    makkah = %Coordinate{latitude: 21.4225, longitude: 39.8261}

    longitude_radian = longitude |> Math.deg2rad()
    latitude_radian = latitude |> Math.deg2rad()
    makkah_latitude_radian = makkah.latitude |> Math.deg2rad()
    makkah_longitude_radian = makkah.longitude |> Math.deg2rad()

    longitude_difference = makkah_longitude_radian - longitude_radian

    term1 = longitude_difference |> Math.sin()

    term2 = latitude_radian |> :math.cos() |> Kernel.*(makkah_latitude_radian |> :math.tan())

    term3 = latitude_radian |> :math.sin() |> Kernel.*(longitude_difference |> :math.cos())

    term1 |> :math.atan2(term2 - term3) |> Math.rad2deg() |> MathUtils.unwind_angle()
  end
end
