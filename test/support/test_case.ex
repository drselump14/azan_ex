defmodule Azan.TestCase do
  @moduledoc """
  Doc for test case
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      use ExUnit.Case, async: true

      import Azan.TestCase
    end
  end

  def assert_to_be_close_to(a, b, digit_precision) do
    assert to_be_close_to(a, b, digit_precision)
  end

  def to_be_close_to(a, b, digit_precision) do
    a
    |> round_decimal_by_digit(digit_precision)
    |> Kernel.==(round_decimal_by_digit(b, digit_precision))
  end

  def round_decimal_by_digit(decimal, digit_precision) do
    decimal
    |> Decimal.from_float()
    |> Decimal.round(digit_precision)
  end
end
