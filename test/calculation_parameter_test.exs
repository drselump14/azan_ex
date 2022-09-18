defmodule CalculationParameterTest do
  @moduledoc """
  Documentation for `CalculationParameterTest`.
  """

  use ExUnit.Case, async: true

  describe "night_portions" do
    test "middle_of_the_night" do
      assert %CalculationParameter{} |> CalculationParameter.night_portions(:middle_of_the_night) ==
               %{fajr: 1 / 2, isha: 1 / 2}
    end

    test "sevent_of_the_night" do
      assert %CalculationParameter{} |> CalculationParameter.night_portions(:sevent_of_the_night) ==
               %{fajr: 1 / 7, isha: 1 / 7}
    end

    test "twilight_angle" do
      assert %CalculationParameter{fajr_angle: 18, isha_angle: 17}
             |> CalculationParameter.night_portions(:twilight_angle) ==
               %{fajr: 18 / 60, isha: 17 / 60}
    end
  end

  describe "adjust_by_method" do
    test "adjusts the method_adjustments" do
      assert %CalculationParameter{}
             |> CalculationParameter.adjust_by_method(:fajr, 10)
             |> Map.get(:method_adjustments) ==
               %{fajr: 10, sunrise: 0, dhuhr: 0, asr: 0, maghrib: 0, isha: 0}
    end
  end
end
