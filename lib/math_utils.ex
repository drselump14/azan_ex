defmodule MathUtils do
  @moduledoc """
  Documentation for `MathUtils`.
  """

  def normalize_to_scale(num, max) do
    num - max * Float.floor(num / max)
  end

  def unwind_angle(angle) do
    angle |> normalize_to_scale(360)
  end

  def quadrant_shift_angle(angle) when angle >= -180 and angle <= 180 do
    angle
  end

  def quadrant_shift_angle(angle) do
    angle - 360 * Float.round(angle / 360)
  end
end
