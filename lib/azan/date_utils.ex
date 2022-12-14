defmodule Azan.DateUtils do
  @moduledoc """
  A collection of date utilities.
  """

  require Logger

  def day_of_year(%Date{} = date) do
    with {:ok, beginning_of_year} <- date |> Timex.beginning_of_year() |> wrap_timex_error(),
         {:ok, diff} <- date |> Timex.diff(beginning_of_year, :days) |> wrap_timex_error() do
      diff |> Kernel.+(1)
    else
      {:error, reason} -> raise reason
    end
  end

  def day_of_year(year, month, day) do
    date = Date.new!(year, month, day)
    day_of_year(date)
  end

  def days_in_year(year) do
    if year |> Timex.is_leap?(), do: 366, else: 365
  end

  def rounded_minute(date, rounding \\ :nearest) do
    %DateTime{second: second} = date |> Timex.Timezone.convert("UTC")

    offset =
      case rounding do
        :up -> 60 - second
        :none -> 0
        _ -> if second >= 30, do: 60 - second, else: -1 * second
      end

    date |> Timex.shift(seconds: offset)
  end

  def shift_by_seconds(%DateTime{} = date, seconds_offset) do
    milliseconds_offset = (seconds_offset * 1000) |> round()
    date |> Timex.shift(milliseconds: milliseconds_offset)
  end

  def sum_adjustment(nil, nil), do: 0
  def sum_adjustment(adjustment_1, nil), do: adjustment_1
  def sum_adjustment(nil, adjustment_2), do: adjustment_2
  def sum_adjustment(adjustment_1, adjustment_2), do: adjustment_1 + adjustment_2

  def rounded_time(prayer_time, adjustment, rounding) do
    prayer_time
    |> Timex.shift(minutes: adjustment)
    |> __MODULE__.rounded_minute(rounding)
  end

  def wrap_timex_error(result) do
    case result do
      {:error, reason} ->
        {:error, reason}

      value ->
        {:ok, value}
    end
  end
end
