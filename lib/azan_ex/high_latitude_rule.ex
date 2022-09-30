defmodule HighLatitudeRule do
  @moduledoc """
  Documentation for `HighLatitudeRule`.
  """

  @spec recommended(Coordinate.t()) :: atom()
  def recommended(%Coordinate{latitude: latitude}) when latitude > 48 do
    :seventh_of_the_night
  end

  def recommended(%Coordinate{} = _) do
    :middle_of_the_night
  end
end
