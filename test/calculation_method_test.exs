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

  test "karachi" do
    assert CalculationMethod.karachi() == %CalculationParameter{
             fajr_angle: 18,
             isha_angle: 18,
             method: :karachi,
             method_adjustments: %{asr: 0, dhuhr: 1, fajr: 0, isha: 0, maghrib: 0, sunrise: 0}
           }
  end

  test "umm_al_quran" do
    assert CalculationMethod.umm_al_quran() == %CalculationParameter{
             fajr_angle: 18.5,
             isha_angle: 0,
             isha_interval: 90,
             method: :umm_al_quran
           }
  end

  test "dubai" do
    assert CalculationMethod.dubai() == %CalculationParameter{
             fajr_angle: 18.2,
             isha_angle: 18.2,
             method: :dubai,
             method_adjustments: %{asr: -3, dhuhr: 3, fajr: 0, isha: 0, maghrib: 3, sunrise: -3}
           }
  end

  test "moonsighting_committee" do
    assert CalculationMethod.moonsighting_committee() == %CalculationParameter{
             fajr_angle: 18,
             isha_angle: 18,
             method: :moonsighting_committee,
             method_adjustments: %{asr: 0, dhuhr: 5, fajr: 0, isha: 0, maghrib: 3, sunrise: 0}
           }
  end

  test "north_america" do
    assert CalculationMethod.north_america() == %CalculationParameter{
             fajr_angle: 15,
             isha_angle: 15,
             method: :north_america,
             method_adjustments: %{asr: 0, dhuhr: 1, fajr: 0, isha: 0, maghrib: 0, sunrise: 0}
           }
  end

  test "kuwait" do
    assert CalculationMethod.kuwait() == %CalculationParameter{
             fajr_angle: 18,
             isha_angle: 17.5,
             method: :kuwait,
             method_adjustments: %{asr: 0, dhuhr: 0, fajr: 0, isha: 0, maghrib: 0, sunrise: 0}
           }
  end

  test "qatar" do
    assert CalculationMethod.qatar() == %CalculationParameter{
             fajr_angle: 18,
             isha_angle: 0,
             isha_interval: 90,
             method: :qatar,
             method_adjustments: %{asr: 0, dhuhr: 0, fajr: 0, isha: 0, maghrib: 0, sunrise: 0}
           }
  end

  test "singapore" do
    assert CalculationMethod.singapore() == %CalculationParameter{
             fajr_angle: 20,
             isha_angle: 18,
             method: :singapore,
             rounding: :up,
             method_adjustments: %{asr: 0, dhuhr: 1, fajr: 0, isha: 0, maghrib: 0, sunrise: 0}
           }
  end

  test "tehran" do
    assert CalculationMethod.tehran() == %CalculationParameter{
             fajr_angle: 17.7,
             isha_angle: 14,
             isha_interval: 4,
             method: :tehran,
             method_adjustments: %{asr: 0, dhuhr: 0, fajr: 0, isha: 0, maghrib: 0, sunrise: 0}
           }
  end

  test "turkey" do
    assert CalculationMethod.turkey() == %CalculationParameter{
             fajr_angle: 18,
             isha_angle: 17,
             method: :turkey,
             method_adjustments: %{asr: 4, dhuhr: 5, fajr: 0, isha: 0, maghrib: 7, sunrise: -7}
           }
  end

  test "other" do
    assert CalculationMethod.other() == %CalculationParameter{
             fajr_angle: 0,
             isha_angle: 0,
             method: :other,
             method_adjustments: %{asr: 0, dhuhr: 0, fajr: 0, isha: 0, maghrib: 0, sunrise: 0}
           }
  end
end
