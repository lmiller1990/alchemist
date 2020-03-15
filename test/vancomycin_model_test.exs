defmodule VancomycinModelTest do
  use ExUnit.Case
  doctest VancomycinModel

  def patient do
    %Patient{age: 60, weight: 75, height: 170, sex: :male}
  end

  test "verify_nonnegative throws an error" do
    expected = "Error: time cannot be less than 0. You passed -1."
    assert catch_throw(VancomycinModel.verify_nonnegative(-1)) == expected
  end

  test "verify_nonnegative" do
    assert VancomycinModel.verify_nonnegative(1) == nil
  end

  test "calculate_secr_at_time - uses response time" do
    res = %Response{time: 1, conc: 5}
    assert VancomycinModel.calculate_secr_at_time(nil, [], [res], patient()) == 1
  end

  test "calculate_secr_at_time - uses dose time" do
    dose = %Dose{time: 1, rate: 50, length: 1}
    assert VancomycinModel.calculate_secr_at_time(nil, [dose], [], patient()) == 1
  end

  test "calculate_secr_at_time - uses 0" do
    assert VancomycinModel.calculate_secr_at_time(nil, [], [], patient()) == 0
  end

  test "get_secr_at_time - success #1" do
    secr = %Response{time: 1, secr: 5}
    conc = %Response{time: 2, conc: 50}
    assert VancomycinModel.get_secr_at_time(1, [secr, conc]) == secr
  end

  test "get_secr_at_time - success #2" do
    secr1 = %Response{time: 1, secr: 5}
    secr2 = %Response{time: 2, secr: 5}
    conc = %Response{time: 1, conc: 50}
    assert VancomycinModel.get_secr_at_time(1, [secr1, secr2, conc]) == secr1
  end

  test "get_secr_at_time - none present" do
    assert VancomycinModel.get_secr_at_time(1, []) == nil
  end

  test "secr_mean" do
    assert VancomycinModel.secr_mean(12, :female) == 48.45351362446261
    assert VancomycinModel.secr_mean(16, :female) == 60.0722
    assert VancomycinModel.secr_mean(16, :male) == 64.90660000000001
    assert VancomycinModel.secr_mean(26, :female) == 69.5
    assert VancomycinModel.secr_mean(26, :male) == 84
  end
end
