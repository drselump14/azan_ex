defmodule TimeComponent do
  @moduledoc """
  Documentation for `TimeComponent`.
  """

  use TypedStruct

  typedstruct do
    field :hour, integer()
    field :minute, integer()
    field :second, integer()
  end

  @doc ~S"""
  Create a new `TimeComponent` from an hour with fractional part.

       ## Examples

        iex> TimeComponent.new(12.5)
        %TimeComponent{hour: 12, minute: 30, second: 0}
  """
  def new(num) do
    hour = num |> floor()
    minute = ((num - hour) * 60) |> floor()
    second = ((num - hour - minute / 60) * 3600) |> floor()
    %__MODULE__{hour: hour, minute: minute, second: second}
  end

  @doc ~S"""
  Convert a `TimeComponent` to a string in the format of "HH:MM".

       ## Examples

        iex> TimeComponent.new(12.5) |> TimeComponent.to_hm_string()
        "12:30"
  """
  def to_hm_string(%__MODULE__{hour: hour, minute: minute, second: second}) do
    hour_string = hour |> Integer.to_string()

    minute_string =
      (minute + round(second / 60)) |> Integer.to_string() |> String.pad_leading(2, "0")

    hour_string <> ":" <> minute_string
  end

  @doc ~S"""
  Create a DateTime from `TimeComponent`

       ## Examples

        iex> TimeComponent.new(12.5) |> TimeComponent.create_utc_datetime(2015, 1, 1)
        ~U[2015-01-01 12:30:00Z]
  """
  def create_utc_datetime(%TimeComponent{hour: hour, minute: minute, second: second}, %Date{
        year: year,
        month: month,
        day: day
      }) do
    create_utc_datetime(
      %TimeComponent{hour: hour, minute: minute, second: second},
      year,
      month,
      day
    )
  end

  def create_utc_datetime(
        %TimeComponent{hour: hour, minute: minute, second: second},
        year,
        month,
        day
      )
      when hour > 23 do
    day_offset = hour |> div(24)
    hour = hour |> rem(24)

    create_utc_datetime(
      %TimeComponent{hour: hour, minute: minute, second: second},
      year,
      month,
      day
    )
    |> Timex.shift(days: day_offset)
  end

  def create_utc_datetime(
        %TimeComponent{hour: hour, minute: minute, second: second},
        year,
        month,
        day
      ) do
    {{year, month, day}, {hour, minute, second}} |> Timex.to_datetime("UTC")
  end
end
