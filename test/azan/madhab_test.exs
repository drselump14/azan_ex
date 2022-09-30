defmodule Azan.MadhabTest do
  @moduledoc """
  Documentation for `MadhabTest`.
  """
  alias Azan.Madhab

  use Azan.TestCase

  test "getting the madhab shadow length" do
    assert :shafi |> Madhab.shadow_length() == 1
    assert :hanafi |> Madhab.shadow_length() == 2
  end
end
