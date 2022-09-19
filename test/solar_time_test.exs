defmodule SolarTimeTest do
  use Azan.TestCase

  test "calculate solar time values" do
    coordinates = %Coordinates{latitude: 35 + 47 / 60, longitude: -78 - 39 / 60}

    solar =
      %SolarTime{transit: transit, sunrise: sunrise, sunset: sunset} =
      SolarTime.new(Date.new!(2015, 6, 12), coordinates)

    twilight_start = solar |> SolarTime.hour_angle(-6, false)
    twilight_end = solar |> SolarTime.hour_angle(-6, true)
    assert_time_string(twilight_start |> TimeComponent.new(), "9:38")
    assert_time_string(sunrise |> TimeComponent.new(), "10:08")
    assert_time_string(transit |> TimeComponent.new(), "17:20")
    assert_time_string(sunset |> TimeComponent.new(), "24:32")
    assert_time_string(twilight_end |> TimeComponent.new(), "25:02")
  end
end
