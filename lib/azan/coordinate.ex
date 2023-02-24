defmodule Azan.Coordinate do
  @moduledoc """
  Documentation for `Coordinate`.
  """

  use TypedStruct
  use Domo

  typedstruct do
    field :latitude, float()
    field :longitude, float()
  end
end
