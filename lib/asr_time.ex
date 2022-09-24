defmodule AsrTime do
  @moduledoc """
  Documentation for `AsrTime`.
  """

  use TypedStruct

  typedstruct do
    field :solar_time, SolarTime.t()
    field :calculation_parameter, CalculationParameter.t()
    field :date, Date.t()
  end

  def find(%__MODULE__{
        solar_time: solar_time,
        date: date,
        calculation_parameter: %CalculationParameter{madhab: madhab}
      }) do
    solar_time
    |> SolarTime.afternoon(madhab |> Madhab.shadow_length())
    |> TimeComponent.new()
    |> TimeComponent.create_utc_datetime(date)
  end
end
