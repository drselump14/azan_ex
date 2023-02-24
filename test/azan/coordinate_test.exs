defmodule Azan.CoordinateTest do
  use Azan.TestCase

  alias Azan.Coordinate

  setup %{} do
    %{
      latitude: Faker.random_uniform(),
      longitude: Faker.random_uniform()
    }
  end

  test "valid value", %{latitude: latitude, longitude: longitude} do
    assert(Coordinate.new!(latitude: latitude, longitude: longitude))
  end

  test "invalid_value" do
    assert({:error, _} = Coordinate.new(latitude: "a", longitude: "b"))
  end
end
