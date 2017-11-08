defmodule DDFloatTest do
  use ExUnit.Case

  import DD.TestHelpers

  
  ####################### fixtures ###########################
  
  defmodule WithInts do
    use DD
    defrecord do
      float(:positive,  default: 123)
      float(:negative,  default: -123)
      float(:string,    default: "123")
      float(:min2,      default: 2, min: 2)
      float(:max4,      default: 3, max: 4)
      float(:min2max4,  default: 4, min: 2, max: 4)
    end
  end

  defmodule WithFloats do
    use DD
    defrecord do
      float(:positive,  default: 123.0)
      float(:negative,  default: -123.0)
      float(:string,    default: "123.0")
      float(:min2,      default: 2.0, min: 2.0)
      float(:max4,      default: 3.0, max: 4.0)
      float(:min2max4,  default: 4.0, min: 2.0, max: 4.0)
    end
  end

  defmodule WithMixed do
    use DD
    defrecord do
      float(:positive,  default: 123.0)
      float(:negative,  default: -123)
      float(:string,    default: "123.0")
      float(:min2,      default: 2, min: 2.0)
      float(:max4,      default: 3.0, max: 4)
      float(:min2max4,  default: 4, min: 2.0, max: 4)
    end
  end
   
  defmodule BadDefault do
    use DD
    defrecord do
      float(:f1, default: :abc)
    end
  end

  ###################### tests ###############################
  
  test "Passing integers to float works" do
    with result = WithInts.new_record() do
      assert result.errors == []
      assert result.values.positive === 123.0
      assert result.values.negative === -123.0
      assert result.values.string   === 123.0
      assert result.values.min2     === 2.0
      assert result.values.max4     === 3.0
      assert result.values.min2max4 === 4.0
      
    end
  end

  test "Passing floats to float works" do
    with result = WithFloats.new_record() do
      assert result.errors == []
      assert result.values.positive === 123.0
      assert result.values.negative === -123.0
      assert result.values.string   === 123.0
      assert result.values.min2     === 2.0
      assert result.values.max4     === 3.0
      assert result.values.min2max4 === 4.0
    end
  end
  
  test "Passing mixed to float works" do
    with result = WithMixed.new_record() do
      assert result.errors == []
      assert result.values.positive === 123.0
      assert result.values.negative === -123.0
      assert result.values.string   === 123.0
      assert result.values.min2     === 2.0
      assert result.values.max4     === 3.0
      assert result.values.min2max4 === 4.0
    end
  end
  
  test "Minimum checked" do
    with result = WithFloats.new_record(min2: 1) do
      assert result.errors == [min2: error("must be at least 2.0 (currently 1.0)")]
  
    end
  end
  
  test "Maximum checked" do
    with result = WithFloats.new_record(max4: 5) do
      assert result.errors == [ max4: error("cannot be greater than 4.0 (currently 5.0)") ]
    end
  end
  
  test "A record with an invalid default is marked in error" do
    with result = BadDefault.new_record() do
      assert result.errors ==  [ f1: error(":abc should be a float") ]
    end
  end
  # # 
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
