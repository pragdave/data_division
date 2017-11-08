defmodule DDIntTest do
  use ExUnit.Case

  import DD.TestHelpers

  
  ####################### fixtures ###########################
  
  defmodule A do
    use DD
    defrecord do
      int(:positive,  default: 123)
      int(:negative,  default: -123)
      int(:string,    default: "123")
      int(:min2,      default: 2, min: 2)
      int(:max4,      default: 3, max: 4)
      int(:min2max4,  default: 4, min: 2, max: 4)
    end
  end
  
  defmodule BadDefault do
    use DD
    defrecord do
      int(:f1, default: :abc)
    end
  end

  ###################### tests ###############################
  
  test "Default values have no errors" do
    with result = A.new_record() do
      assert result.errors == []
      assert result.values.positive == 123
      assert result.values.negative == -123
      assert result.values.string   == 123
    end
  end

  test "Minimum checked" do
    with result = A.new_record(min2: 1) do
      assert result.errors == [min2: error("must be at least 2 (currently 1)")]
  
    end
  end
  
  test "Maximum checked" do
    with result = A.new_record(max4: 5) do
      assert result.errors == [ max4: error("cannot be greater than 4 (currently 5)") ]
    end
  end
  
  test "A record with an invalid default is marked in error" do
    with result = BadDefault.new_record() do
      assert result.errors ==  [ f1: error(":abc should be an integer") ]
    end
  end
  # 
  # test "good options are accepted" do
  #   alias DD.Type.String, as: DTS
  # 
  #   [
  #     pass_expect([]),
  # 
  #     # global options
  #     
  #     pass_expect(default: 99),
  # 
  #   # string options
  #     
  #     pass_expect(min: 3, max: 5),
  #     pass_expect(matches: ~r/123/),
  # 
  #     # string in match is converted to a Regex
  #     
  #     pass_expect([matches: "123"], [matches: ~r/123/]),
  #   ]
  #   |> IO.inspect
  #   |> Enum.each(fn { pass, expect } ->
  #     {{_name, %{ options: options, type: type}}, _} =
  #       DTS.from_spec(:name, pass) |> Code.eval_quoted
  #     
  #     assert options == expect
  #     assert type == DTS
  #     end)
  # end
  # 
  # test "bad options are rejected" do
  #   alias DD.Type.String, as: DTS
  # 
  #   [
  #     [ wombat: 99 ],
  #     [ min: -1 ],
  #     [ min: "cow" ],
  #     [ max: -1 ],
  #   ]
  #   |> Enum.each(fn option ->
  #        assert_raise(RuntimeError, ~r/Invalid constraint:/, fn ->
  #          DTS.from_spec(:name, option)
  #        end)
  #     end)
  # end
  # 
  # defp pass_expect(opts), do: { opts, opts }
  # 
  # defp pass_expect(pass, expect), do: { pass, expect }
  # 
end
