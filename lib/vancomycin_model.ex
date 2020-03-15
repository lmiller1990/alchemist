require Math

defmodule Dose do
  @enforce_keys [:time, :rate, :length]
  defstruct [:time, :rate, :length]
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
  def hello do
    %Patient{age: 60, weight: 75, height: 170, sex: :male}
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

  def get_serum_level(time) do
    VancomycinModel.verify_nonnegative(time)
  end

  def format(patient, doses, _responses) do
    IO.puts("Age: #{patient[:age]}, weight: #{patient[:weight]}, sex: #{patient[:sex]}")
    IO.puts("Doses")
    for dose <- doses do
      IO.puts("#{dose[:rate]}mg at t#{dose[:time]} over at #{dose[:time]}")
    end
  end

  def run(_patient, _doses, _responses) do
    Enum.each(0..24, &VancomycinModel.get_serum_level/1)
  end
end
