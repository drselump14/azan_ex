defmodule MadhabTest do
  @moduledoc """
  Documentation for `MadhabTest`.
  """
  use Azan.TestCase

  test "getting the madhab shadow length" do
    assert :shafi |> Madhab.shadow_length() == 1
    assert :hanafi |> Madhab.shadow_length() == 2
  end
end
