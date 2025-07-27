defmodule Azan.CalculationMethod do
  @moduledoc """
  Documentation for `CalculationMethod`.
  """

  alias Azan.CalculationParameter

  def muslim_world_league do
    %CalculationParameter{
      method: :muslim_world_league,
      fajr_angle: 18.0,
      isha_angle: 17.0
    }
    |> CalculationParameter.adjust_by_method(:dhuhr, 1)
  end

  def egyptian do
    %CalculationParameter{
      method: :egyptian,
      fajr_angle: 19.5,
      isha_angle: 17.5
    }
    |> CalculationParameter.adjust_by_method(:dhuhr, 1)
  end

  def karachi do
    %CalculationParameter{
      method: :karachi,
      fajr_angle: 18.0,
      isha_angle: 18.0
    }
    |> CalculationParameter.adjust_by_method(:dhuhr, 1)
  end

  def umm_al_quran do
    %CalculationParameter{
      method: :umm_al_quran,
      fajr_angle: 18.5,
      isha_angle: 0,
      isha_interval: 90
    }
  end

  def dubai do
    %CalculationParameter{
      method: :dubai,
      fajr_angle: 18.2,
      isha_angle: 18.2
    }
    |> CalculationParameter.adjust_by_method(:sunrise, -3)
    |> CalculationParameter.adjust_by_method(:dhuhr, 3)
    |> CalculationParameter.adjust_by_method(:asr, -3)
    |> CalculationParameter.adjust_by_method(:maghrib, 3)
  end

  def moonsighting_committee do
    params = %CalculationParameter{
      method: :moonsighting_committee,
      fajr_angle: 18.0,
      isha_angle: 18.0
    }

    params
    |> CalculationParameter.adjust_by_method(:dhuhr, 5)
    |> CalculationParameter.adjust_by_method(:maghrib, 3)
  end

  def north_america do
    %CalculationParameter{
      method: :north_america,
      fajr_angle: 15,
      isha_angle: 15
    }
    |> CalculationParameter.adjust_by_method(:dhuhr, 1)
  end

  def kuwait do
    %CalculationParameter{
      method: :kuwait,
      fajr_angle: 18.0,
      isha_angle: 17.5
    }
  end

  def qatar do
    %CalculationParameter{
      method: :qatar,
      fajr_angle: 18.0,
      isha_angle: 0,
      isha_interval: 90
    }
  end

  def singapore do
    %CalculationParameter{
      method: :singapore,
      fajr_angle: 20.0,
      isha_angle: 18.0,
      rounding: :up
    }
    |> CalculationParameter.adjust_by_method(:dhuhr, 1)
  end

  @spec tehran() :: CalculationParameter.t()
  def tehran do
    %CalculationParameter{
      method: :tehran,
      fajr_angle: 17.7,
      isha_angle: 14.0,
      isha_interval: 4
    }
  end

  def turkey do
    %CalculationParameter{
      method: :turkey,
      fajr_angle: 18.0,
      isha_angle: 17.0
    }
    |> CalculationParameter.adjust_by_method(:sunrise, -7)
    |> CalculationParameter.adjust_by_method(:dhuhr, 5)
    |> CalculationParameter.adjust_by_method(:asr, 4)
    |> CalculationParameter.adjust_by_method(:maghrib, 7)
  end

  def other do
    %CalculationParameter{
      method: :other,
      fajr_angle: 0,
      isha_angle: 0
    }
  end
end
