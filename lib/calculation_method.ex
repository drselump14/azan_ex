defmodule CalculationMethod do
  @moduledoc """
  Documentation for `CalculationMethod`.
  """

  def muslim_world_league() do
    params = %CalculationParameter{
      method: "Muslim World League",
      fajr_angle: 18,
      isha_angle: 17
    }

    params |> CalculationParameter.adjust(:dhuhr, 1)
  end
end
