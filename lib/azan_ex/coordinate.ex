defmodule Coordinate do
  @moduledoc """
  Documentation for `Coordinate`.
  """

  use TypedStruct

  typedstruct do
    field :latitude, float()
    field :longitude, float()
  end

  def new(latitude, longitude) do
    %__MODULE__{
      latitude: latitude,
      longitude: longitude
    }
  end
end
