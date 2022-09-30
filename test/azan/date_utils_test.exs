defmodule Azan.DateUtilsTest do
  @moduledoc """
  Tests for `DateUtils`.
  """

  alias Azan.DateUtils

  use ExUnit.Case, async: true

  test "day_of_year" do
    date = Date.new!(2018, 1, 31)
    assert date |> DateUtils.day_of_year() == 31
  end
end
