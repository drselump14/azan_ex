defmodule SolarTimeTest do
  @moduledoc """
  Documentation for `SolarTimeTest`.
  """

  use Azan.TestCase

  require Logger

  test "calculate solar time values" do
    coordinate = %Coordinate{latitude: 35 + 47 / 60, longitude: -78 - 39 / 60}

    solar =
      %SolarTime{transit: transit, sunrise: sunrise, sunset: sunset} =
      SolarTime.new(Date.new!(2015, 7, 12), coordinate)

    twilight_start = solar |> SolarTime.hour_angle(-6, false)
    twilight_end = solar |> SolarTime.hour_angle(-6, true)

    assert_time_string(
      twilight_start |> TimeComponent.new(),
      "9:38"
    )

    assert_time_string(
      sunrise |> TimeComponent.new(),
      "10:08"
    )

    assert_time_string(
      transit |> TimeComponent.new(),
      "17:20"
    )

    assert_time_string(
      sunset |> TimeComponent.new(),
      "24:32"
    )

    assert_time_string(
      twilight_end |> TimeComponent.new(),
      "25:02"
    )
  end

  # test "verify the correct calendar date is being used for calculations" do
  #   coordinate = %Coordinate{latitude: 20 + 7 / 60, longitude: -155 - 34 / 60}
  #   day1solar = SolarTime.new(Date.new!(2015, 3, 2), coordinate)
  #   day2solar = SolarTime.new(Date.new!(2015, 3, 3), coordinate)
  #
  #   day1 = day1solar.sunrise
  #   day2 = day2solar.sunrise
  #
  #   assert assert_time_string(TimeComponent.new(day1), "16:15")
  #   assert assert_time_string(TimeComponent.new(day2), "16:14")
  # end
end
