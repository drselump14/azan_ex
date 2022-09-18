defmodule CalculationMethodTest do
  use ExUnit.Case, async: true

  test "muslim_world_league" do
    assert CalculationMethod.muslim_world_league() == %CalculationParameter{
             fajr_angle: 18,
             isha_angle: 17,
             method: "Muslim World League",
             method_adjustments: %{asr: 0, dhuhr: 1, fajr: 0, isha: 0, maghrib: 0, sunrise: 0}
           }
  end
end
