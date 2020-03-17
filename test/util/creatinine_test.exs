defmodule VancomycinModel.Util.CreatinineTest do
  use ExUnit.Case
  alias Util.Creatinine

  test "secr_mean" do
    assert Creatinine.secr_mean(12, :female) == 48.45351362446261
    assert Creatinine.secr_mean(16, :female) == 60.0722
    assert Creatinine.secr_mean(16, :male) == 64.90660000000001
    assert Creatinine.secr_mean(26, :female) == 69.5
    assert Creatinine.secr_mean(26, :male) == 84
  end
end
