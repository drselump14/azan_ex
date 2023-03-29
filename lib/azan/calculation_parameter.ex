defmodule Azan.CalculationParameter do
  @moduledoc """
  Documentation for `CalculationParameter`.
  """
  use TypedStruct
  use Domo

  typedstruct do
    field :method, atom(), default: :other
    field :fajr_angle, float(), default: 0.0
    field :isha_angle, float(), default: 0.0
    field :isha_interval, integer(), default: 0
    field :maghrib_angle, float(), default: 0.0

    field :method_adjustments, map(),
      default: %{fajr: 0, sunrise: 0, dhuhr: 0, asr: 0, maghrib: 0, isha: 0}

    field :adjustments, map(),
      default: %{fajr: 0, sunrise: 0, dhuhr: 0, asr: 0, maghrib: 0, isha: 0}

    field :madhab, atom(), default: :shafi

    field :shafaq, atom(), default: :general

    field :high_latitude_rule, atom(), default: :middle_of_the_night
    field :polar_circle_resolution, atom(), default: :unresolved
    field :rounding, atom(), default: :nearest
  end

  def night_portions(%__MODULE__{high_latitude_rule: :middle_of_the_night}) do
    %{
      fajr: 1 / 2,
      isha: 1 / 2
    }
  end

  def night_portions(%__MODULE__{high_latitude_rule: :seventh_of_the_night}) do
    %{
      fajr: 1 / 7,
      isha: 1 / 7
    }
  end

  def night_portions(%__MODULE__{
        fajr_angle: fajr_angle,
        isha_angle: isha_angle,
        high_latitude_rule: :twilight_angle
      }) do
    %{
      fajr: fajr_angle / 60,
      isha: isha_angle / 60
    }
  end

  def adjust_by_method(
        %__MODULE__{method_adjustments: method_adjustments} = calculation_parameter,
        prayer_time_category,
        offset
      ) do
    new_method_adjustments = method_adjustments |> Map.put(prayer_time_category, offset)
    %__MODULE__{calculation_parameter | method_adjustments: new_method_adjustments}
  end
end
