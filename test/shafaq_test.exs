defmodule ShafaqTest do
  @moduledoc """
  This module contains tests for the `Shafaq` module.
  """
  use ExUnit.Case, async: true

  alias Shafaq

  test "default value testing" do
    assert %Shafaq{general: "general", ahmer: "ahmer", abyad: "abyad"} = Shafaq |> struct()
  end
end
