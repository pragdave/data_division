defmodule DDIdTest do
  use ExUnit.Case

  import DD.TestHelpers

  
  ####################### fixtures ###########################
  
  defmodule A do
    use DD
    deffieldset do
      id(:id)
    end
  end
    
  ###################### tests ###############################
  
  test "IDs are optional and hidden" do
    with result = A.new() do
      assert result.errors == []
      assert result.values.id == nil
    end
  end
  test "invalid string values are detected" do
    defmodule B do
      use DD
      deffieldset do
        id(:a)
      end
    end

    result = B.new(a: "123 abc")
    assert_errors(result,
      a: { "should be an integer", value: "\"123 abc\"" })
  end

end
