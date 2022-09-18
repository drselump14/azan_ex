defmodule CalculationMethod do
  @moduledoc """
  Documentation for `CalculationMethod`.
  """

  def muslim_world_league() do
    %CalculationParameter{
      method: "Muslim World League",
      fajr_angle: 18,
      isha_angle: 17
    }
    |> CalculationParameter.adjust_by_method(:dhuhr, 1)
  end

  def egyptian() do
    %CalculationParameter{
      method: "Egyptian General Authority of Survey",
      fajr_angle: 19.5,
      isha_angle: 17.5
    }
    |> CalculationParameter.adjust_by_method(:dhuhr, 1)
  end

  def karachi() do
    %CalculationParameter{
      method: "University of Islamic Sciences, Karachi",
      fajr_angle: 18,
      isha_angle: 18
    }
    |> CalculationParameter.adjust_by_method(:dhuhr, 1)
  end

  def umm_al_quran() do
    %CalculationParameter{
      method: "Umm al-Qura University, Makkah",
      fajr_angle: 18.5,
      isha_angle: 0,
      isha_interval: 90
    }
  end

  def dubai() do
    %CalculationParameter{
      method: "The General Authority of Islamic Affairs and Endowments, Dubai",
      fajr_angle: 18.2,
      isha_angle: 18.2
    }
    |> CalculationParameter.adjust_by_method(:sunrise, -3)
    |> CalculationParameter.adjust_by_method(:dhuhr, 3)
    |> CalculationParameter.adjust_by_method(:ashar, -3)
    |> CalculationParameter.adjust_by_method(:maghrib, 3)
  end

  def moonsighting_committee() do
    params = %CalculationParameter{
      method: "Moonsighting Committee",
      fajr_angle: 18,
      isha_angle: 18
    }

    params
    |> CalculationParameter.adjust_by_method(:dhuhr, 5)
    |> CalculationParameter.adjust_by_method(:maghrib, 3)
  end

  def north_america() do
    %CalculationParameter{
      method: "Islamic Society of North America",
      fajr_angle: 15,
      isha_angle: 15
    }
    |> CalculationParameter.adjust_by_method(:dhuhr, 1)
  end

  def kuwait() do
    %CalculationParameter{
      method: "Ministry of Awqaf and Islamic Affairs, Kuwait",
      fajr_angle: 18,
      isha_angle: 17.5
    }
  end

  def qatar() do
    %CalculationParameter{
      method: "Qatar",
      fajr_angle: 18,
      isha_angle: 0,
      isha_interval: 90
    }
  end

  def singapore() do
    %CalculationParameter{
      method: "Islamic Religious Council of Singapore",
      fajr_angle: 20,
      isha_angle: 18
    }
  end

  def tehran() do
    %CalculationParameter{
      method: "Institute of Geophysics, University of Tehran",
      fajr_angle: 17.7,
      isha_angle: 14,
      isha_interval: 4
    }
  end
end
