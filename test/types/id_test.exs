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

end
