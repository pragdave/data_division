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

  defmodule DisplayValue1 do
    use DD
    defrecord do
      float(:a, default: 1.25)
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
  
  test "Passing strings to float works" do
    with result = WithMixed.new_record() do
      assert result.errors == []
      result = result |> WithMixed.update(positive: "3.25")
      assert result.errors == []
      assert result.values.positive == 3.25
    end
  end

  test "Passing invalid strings to float causes an error" do
    with result = WithMixed.new_record(positive: "1.2 wombats") do
      assert_errors(result,
        positive: { "should be a float", value: "\"1.2 wombats\"" })
    end
  end
  
  test "Minimum checked" do
    with result = WithFloats.new_record(min2: 1) do
      assert_errors(result,
        min2: { "must be at least", min: 2, value: 1.0 }
      )
  
    end
  end
  
  test "Maximum checked" do
    with result = WithFloats.new_record(max4: 5) do
      assert_errors(result,
        max4: { "cannot be greater than", max: 4.0, value: 5.0 }
        )
    end
  end
  
  test "A record with an invalid default is marked in error" do
    with result = BadDefault.new_record() do
      assert_errors(result, f1: {"should be a float", value: ":abc"})
    end
  end

  test "Default to_display_value works" do
    with result = DisplayValue1.new_record() do
      assert to_string(result) =~ ~r/a:\s+1\.25/
    end
  end

  test "Options must be floats" do
    assert_raise(RuntimeError, ~r/invalid float/, fn ->
      defmodule BadOpt do
        use DD
        defrecord do
          float(:a, default: 2, min: "wombat")
        end
      end
    end)


    assert_raise(RuntimeError, ~r/invalid float/, fn ->
      defmodule BadOpt do
        use DD
        defrecord do
          float(:a, default: 2, max: "wombat")
        end
      end
    end)
  end
    
end
