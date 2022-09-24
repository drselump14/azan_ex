defmodule FajrTime do
  @moduledoc """
  Documentation for `FajrTime`.
  """

  use TypedStruct

  typedstruct do
    field :calculation_parameter, CalculationParameter.t()
    field :sunrise_time, DateTime.t()
    field :night, number()
    field :latitude, number()
    field :date, Date.t()
    field :solar_time, SolarTime.t()
  end

  def find(%__MODULE__{
        calculation_parameter:
          %CalculationParameter{method: method, fajr_angle: fajr_angle} = calculation_parameter,
        solar_time: solar_time,
        sunrise_time: sunrise_time,
        night: night,
        latitude: latitude,
        date: date
      }) do
    naive_fajr_time =
      solar_time
      |> naive_fajr_time(fajr_angle, date)
      |> consider_latitude_and_method(night, method, latitude)

    safe_fajr =
      %SafeFajr{
        calculation_parameter: calculation_parameter,
        sunrise_time: sunrise_time,
        night: night,
        latitude: latitude,
        date: date
      }
      |> SafeFajr.find_time()

    naive_fajr_time |> naive_or_safe_fajr(safe_fajr)
  end

  def naive_fajr_time(%SolarTime{} = solar_time, fajr_angle, date) do
    solar_time
    |> SolarTime.hour_angle(-1 * fajr_angle, false)
    |> TimeComponent.new()
    |> TimeComponent.create_utc_datetime(date)
  end

  @spec consider_latitude_and_method(DateTime.t(), number, atom(), number()) :: DateTime.t()
  def consider_latitude_and_method(fajr_time, night, :moonsighting_committee, latitude)
      when latitude >= 55 do
    night_fraction = night / 7
    fajr_time |> DateUtils.shift_by_seconds(-1 * night_fraction)
  end

  def consider_latitude_and_method(fajr_time, _night, _method, _latitude), do: fajr_time

  def naive_or_safe_fajr({:error, :invalid_date}, safe_fajr_time), do: safe_fajr_time

  def naive_or_safe_fajr(naive_fajr_time, safe_fajr_time) when safe_fajr_time > naive_fajr_time,
    do: safe_fajr_time

  def naive_or_safe_fajr(naive_fajr_time, _), do: naive_fajr_time
end
