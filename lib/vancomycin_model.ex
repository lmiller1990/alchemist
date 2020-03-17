require Math

defmodule Dose do
  @enforce_keys [:time, :rate, :length]
  defstruct [:time, :rate, :length]
end

defmodule StaticValues do
  def min_conc_per_dose do
    1.0e-8
  end

  def tau do
    12
  end
end

defmodule Response do
  @enforce_keys [:time]
  defstruct [:time, :conc, :secr]
end

defmodule Patient do
  @enforce_keys [:age, :weight, :sex]
  defstruct [:age, :weight, :height, :sex]
end

defmodule VancomycinModel do
  def patient do
    %Patient{age: 60, weight: 70, height: 170, sex: :male}
  end

  def doses do
    [%Dose{time: 0, rate: 500, length: 1}]
  end

  def responses do
    [%Response{time: 0, secr: 90}]
  end

  def secr_mean(age, sex) do
    cond do 
      age <= 15 -> -2.37330 - (12.91367 * Math.log(age)) + (23.93581 * Math.sqrt(age))
      age > 15 && age < 18 && sex == :female -> 4.7137 * age - 15.347
      age > 15 && age < 18 && sex == :male -> 9.5471 * age - 87.847;
      age > 18 && sex == :female -> 69.5
      age > 18 && sex == :male -> 84
    end
  end

  def calculate_secr_at_time(time, doses, responses, patient) do
    t = cond do
      time == nil && List.first(responses) -> List.first(responses).time
      time == nil && List.first(doses)     -> List.first(doses).time
      true -> 0
    end

    if t, do: t, else: secr_mean(patient.age, patient.sex)
  end

  def get_secr_at_time(time, responses) do
    found = Enum.filter(responses, fn x -> x.secr && x.time == time end)
    case found do
      [head] -> head
      [head | _tail] -> head
      [] -> nil
    end
  end

  def verify_nonnegative(time) do
    if time < 0, do: throw("Error: time cannot be less than 0. You passed #{time}.")
  end

  def get_conc(t, dose) do
    k0_t = dose.time
    k0 = dose.rate
    tinf = dose.length
    time_from_this_dose = t - k0_t
    get_single_dose_serum_level(0, k0, tinf, time_from_this_dose, t)
  end

  def vd_param() do
    0.98
  end

  # TODO: cockcroft_gault and the other one
  def cl(t) do
    secr = VancomycinModel.get_secr_at_time(t, VancomycinModel.responses())

    # we want this in L/h 
    # TODO: find out why this is in L/h
    76 * 60 / 1000
  end

  def vd(t) do
    VancomycinModel.patient().weight * vd_param()
  end

  def kel(t) do
    VancomycinModel.cl(t) / VancomycinModel.vd(t)
  end

  def get_single_dose_serum_level(k0_t, k0, tinf, t, time_of_dose) do
    kel = VancomycinModel.kel(t)
    vd = VancomycinModel.vd(t)
    tic = k0_t + tinf
    ( (k0 / (kel * vd)) * (1 - Math.exp(-1 * kel * tic)) * Math.exp(-1 * kel * (t - tic)))
  end

  def get_serum_level(time, doses) do
    VancomycinModel.verify_nonnegative(time)
    Enum.map(doses, fn x -> get_conc(time, x) end)
    |> Enum.sum
  end

  def run(times) do
    Enum.map(times, fn x -> VancomycinModel.get_serum_level(x, doses()) end)
  end
end
