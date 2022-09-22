defmodule DateUtils do
  @moduledoc """
  A collection of date utilities.
  """

  def day_of_year(%Date{} = date) do
    date
    |> Timex.diff(date |> Timex.beginning_of_year(), :days)
    |> Kernel.+(1)
  end

  def day_of_year(year, month, day) do
    date = Date.new!(year, month, day)
    day_of_year(date)
  end

  def days_in_year(year) do
    if year |> Timex.is_leap?(), do: 366, else: 365
  end
end
