defmodule Shafaq do
  @moduledoc """
  Documentation for `Shafaq`.
  """

  use TypedStruct

  typedstruct do
    field :general, String.t(), default: "general"
    field :ahmer, String.t(), default: "ahmer"
    field :abyad, String.t(), default: "abyad"
  end
end
