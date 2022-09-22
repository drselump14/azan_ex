defmodule CalculationParameter do
  @moduledoc """
  Documentation for `CalculationParameter`.
  """
  use TypedStruct

  typedstruct do
    field :method, String.t(), default: "Other"
    field :fajr_angle, float(), default: 0
    field :isha_angle, float(), default: 0
    field :isha_interval, integer(), default: 0
    field :maghrib_angle, float(), default: 0

    field :method_adjustments, map(),
      default: %{fajr: 0, sunrise: 0, dhuhr: 0, asr: 0, maghrib: 0, isha: 0}

    field :adjustments, map(),
      default: %{fajr: 0, sunrise: 0, dhuhr: 0, asr: 0, maghrib: 0, isha: 0}

    field :madhab, String.t(), default: "Shafi"

    field :high_latitude_rule, String.t(), default: :middle_of_the_night
    field :polar_circle_resolution, String.t(), default: :unresolved
  end

  def night_portions(%CalculationParameter{}, :middle_of_the_night) do
    %{
      fajr: 1 / 2,
      isha: 1 / 2
    }
  end

  def night_portions(%CalculationParameter{}, :sevent_of_the_night) do
    %{
      fajr: 1 / 7,
      isha: 1 / 7
    }
  end

  def night_portions(
        %CalculationParameter{fajr_angle: fajr_angle, isha_angle: isha_angle},
        :twilight_angle
      ) do
    %{
      fajr: fajr_angle / 60,
      isha: isha_angle / 60
    }
  end

  def adjust_by_method(
        %CalculationParameter{method_adjustments: method_adjustments} = calculation_parameter,
        prayer_time_category,
        offset
      ) do
    new_method_adjustments = method_adjustments |> Map.put(prayer_time_category, offset)
    %CalculationParameter{calculation_parameter | method_adjustments: new_method_adjustments}
  end
end
