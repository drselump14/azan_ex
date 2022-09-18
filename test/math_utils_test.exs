defmodule MathUtilsTest do
  @moduledoc """
  Tests for `MathUtils`.
  """
  use ExUnit.Case, async: true

  describe "normalize_to_scale" do
    test "default" do
      assert MathUtils.normalize_to_scale(2.0, -5) == -3
      assert MathUtils.normalize_to_scale(-4, -5) == -4

      assert MathUtils.normalize_to_scale(-6, -5) == -1

      assert MathUtils.normalize_to_scale(-1, 24) == 23
      assert MathUtils.normalize_to_scale(1, 24) == 1
      assert MathUtils.normalize_to_scale(49.0, 24) == 1

      assert MathUtils.normalize_to_scale(361, 360) == 1
      assert MathUtils.normalize_to_scale(360, 360) == 0
      assert MathUtils.normalize_to_scale(259, 360) == 259
      assert MathUtils.normalize_to_scale(2592.0, 360) == 72
    end
  end

  describe "unwind_angle" do
    test "default" do
      assert MathUtils.unwind_angle(-45) == 315
      assert MathUtils.unwind_angle(361.0) == 1
      assert MathUtils.unwind_angle(360) == 0
      assert MathUtils.unwind_angle(259.0) == 259
      assert MathUtils.unwind_angle(2592) == 72
    end
  end

  describe "quadrant_shift_angle" do
    test "default" do
      assert MathUtils.quadrant_shift_angle(360.0) == 0
      assert MathUtils.quadrant_shift_angle(361.0) == 1
      assert MathUtils.quadrant_shift_angle(1.0) == 1
      assert MathUtils.quadrant_shift_angle(-1.0) == -1
      assert MathUtils.quadrant_shift_angle(-181.0) == 179
      assert MathUtils.quadrant_shift_angle(180.0) == 180
      assert MathUtils.quadrant_shift_angle(359.0) == -1
      assert MathUtils.quadrant_shift_angle(-359.0) == 1
      assert MathUtils.quadrant_shift_angle(1261.0) == -179
    end
  end
end
