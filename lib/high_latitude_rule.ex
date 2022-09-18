defmodule HighLatitudeRule do
  @moduledoc """
  Documentation for `HighLatitudeRule`.
  """

  @spec recommended(Coordinates.t()) :: String.t()
  def recommended(%Coordinates{latitude: latitude}) when latitude > 48 do
    "sevent_of_the_night"
  end

  def recommended(%Coordinates{} = _) do
    "middle_of_the_night"
  end
end
