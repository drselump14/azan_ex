defmodule CalculationMethodTest do
  @moduledoc """
  Documentation for `CalculationMethodTest`.
  """

  use ExUnit.Case, async: true

  test "muslim_world_league" do
    assert CalculationMethod.muslim_world_league() == %CalculationParameter{
             fajr_angle: 18,
             isha_angle: 17,
             method: :muslim_world_league,
             method_adjustments: %{asr: 0, dhuhr: 1, fajr: 0, isha: 0, maghrib: 0, sunrise: 0}
           }
  end

  test "egyptian" do
    assert CalculationMethod.egyptian() == %CalculationParameter{
             fajr_angle: 19.5,
             isha_angle: 17.5,
             method: :egyptian,
             isha_interval: 0,
             method_adjustments: %{asr: 0, dhuhr: 1, fajr: 0, isha: 0, maghrib: 0, sunrise: 0}
           }
  end
end
