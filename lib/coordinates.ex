defmodule Coordinates do
  @moduledoc """
  Documentation for `Coordinates`.
  """

  use TypedStruct

  typedstruct do
    field :latitude, float()
    field :longitude, float()
  end
end
