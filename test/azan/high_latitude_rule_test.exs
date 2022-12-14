defmodule Azan.HighLatitudeRuleTest do
  @moduledoc """
  Documentation for `HighLatitudeRuleTest`.
  """

  alias Azan.{
    Coordinate,
    HighLatitudeRule
  }

  use ExUnit.Case, async: true

  describe "recommended" do
    test "if latitude is less than 48" do
      assert %Coordinate{latitude: 47.5} |> HighLatitudeRule.recommended() ==
               :middle_of_the_night
    end

    test "if latitude is more than 48" do
      assert %Coordinate{latitude: 49.5} |> HighLatitudeRule.recommended() ==
               :seventh_of_the_night
    end
  end
end
