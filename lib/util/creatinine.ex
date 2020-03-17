defmodule Util.Creatinine do
  def secr_mean(age, sex) do
    cond do 
      age <= 15 -> -2.37330 - (12.91367 * Math.log(age)) + (23.93581 * Math.sqrt(age))
      age > 15 && age < 18 && sex == :female -> 4.7137 * age - 15.347
      age > 15 && age < 18 && sex == :male -> 9.5471 * age - 87.847
      age > 18 && sex == :female -> 69.5
      age > 18 && sex == :male -> 84
    end
  end
end

