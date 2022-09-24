defmodule Coordinate do
  @moduledoc """
  Documentation for `Coordinate`.
  """

  use TypedStruct

  typedstruct do
    field :latitude, float()
    field :longitude, float()
  end
end
