defmodule Azan.TimeComponentTest do
  @moduledoc """
  Documentation for `TimeComponentTest`.
  """

  use ExUnit.Case, async: true

  alias Azan.TimeComponent

  doctest(TimeComponent)

  test "new/1" do
    assert %TimeComponent{hour: 12, minute: 30, second: 0} == TimeComponent.new(12.5)
    assert %TimeComponent{hour: 12, minute: 15, second: 0} == TimeComponent.new(12.25)
  end

  test "to_hm_string/1" do
    assert "12:30" == TimeComponent.new(12.5) |> TimeComponent.to_hm_string()
    assert "12:15" == TimeComponent.new(12.25) |> TimeComponent.to_hm_string()
  end

  test "create_utc_datetime/2" do
    assert ~U[2015-01-01 12:30:00Z] ==
             TimeComponent.new(12.5) |> TimeComponent.create_utc_datetime(2015, 1, 1)
  end
end
