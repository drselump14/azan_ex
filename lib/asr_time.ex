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

  def find!(%__MODULE__{
        solar_time: solar_time,
        date: date,
        calculation_parameter: %CalculationParameter{madhab: madhab}
      }) do
    solar_time
    |> SolarTime.afternoon(madhab |> Madhab.shadow_length())
    |> TimeComponent.new()
    |> TimeComponent.create_utc_datetime(date)
  end

  def find(
        solar_time,
        date,
        %CalculationParameter{} = calculation_parameter
      ) do
    {:ok,
     %__MODULE__{
       solar_time: solar_time,
       date: date,
       calculation_parameter: calculation_parameter
     }
     |> __MODULE__.find!()}
  end

  def adjust(datetime, %CalculationParameter{
        adjustments: %{asr: adjustment},
        method_adjustments: %{asr: method_adjustment},
        rounding: rounding
      }) do
    adjustment = adjustment |> DateUtils.sum_adjustment(method_adjustment)
    datetime |> DateUtils.rounded_time(adjustment, rounding)
  end
end
