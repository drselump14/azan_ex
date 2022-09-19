defmodule TimeComponent do
  @moduledoc """
  Documentation for `TimeComponent`.
  """

  use TypedStruct

  typedstruct do
    field :hour, integer()
    field :minute, integer()
    field :second, integer()
  end

  def new(num) do
    hour = num |> floor()
    minute = ((num - hour) * 60) |> floor()
    second = ((num - hour - minute / 60) * 3600) |> floor()
    %__MODULE__{hour: hour, minute: minute, second: second}
  end

  def to_hm_string(%__MODULE__{hour: hour, minute: minute, second: second}) do
    hour_string = hour |> Integer.to_string()

    minute_string =
      (minute + round(second / 60)) |> Integer.to_string() |> String.pad_leading(2, "0")

    hour_string <> ":" <> minute_string
  end
end
