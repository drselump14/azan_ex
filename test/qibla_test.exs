defmodule QiblaTest do
  @moduledoc """
  Documentation for `QiblaTest`.
  """

  use Azan.TestCase

  test "finding Qibla in North America" do
    washington_coordinate = %Coordinate{latitude: 38.9072, longitude: -77.0369}
    assert_to_be_close_to(washington_coordinate |> Qibla.find(), 56.56, 2)

    nyc_coordinate = %Coordinate{latitude: 40.7128, longitude: -74.0060}
    assert_to_be_close_to(nyc_coordinate |> Qibla.find(), 58.4817, 3)

    san_fransisco_coordinate = %Coordinate{latitude: 37.7749, longitude: -122.4194}
    assert_to_be_close_to(san_fransisco_coordinate |> Qibla.find(), 18.8438, 3)

    anchorage_coordinate = %Coordinate{latitude: 61.2181, longitude: -149.9003}
    assert_to_be_close_to(anchorage_coordinate |> Qibla.find(), 350.883, 3)
  end

  test "finding Qibla in the South Pacific" do
    sydney = %Coordinate{latitude: -33.8688, longitude: 151.2093}
    assert_to_be_close_to(sydney |> Qibla.find(), 277.4996, 3)

    auckland = %Coordinate{latitude: -36.8485, longitude: 174.7633}
    assert_to_be_close_to(auckland |> Qibla.find(), 261.197, 3)
  end

  test "finding Qibla in Europe" do
    london = %Coordinate{latitude: 51.5074, longitude: -0.1278}
    assert_to_be_close_to(london |> Qibla.find(), 118.987, 3)

    paris = %Coordinate{latitude: 48.8566, longitude: 2.3522}
    assert_to_be_close_to(paris |> Qibla.find(), 119.163, 3)

    oslo = %Coordinate{latitude: 59.9139, longitude: 10.7522}
    assert_to_be_close_to(oslo |> Qibla.find(), 139.0278, 3)
  end

  test "finding Qibla in Asia" do
    islamabad = %Coordinate{latitude: 33.7294, longitude: 73.0931}
    assert_to_be_close_to(islamabad |> Qibla.find(), 255.882, 3)

    tokyo = %Coordinate{latitude: 35.6895, longitude: 139.6917}
    assert_to_be_close_to(tokyo |> Qibla.find(), 293.021, 3)
  end
end
