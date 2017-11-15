# this isn't a valid type module
defmodule DD.Type.Isnt do
end
  
defmodule CustomTypeTest do
  use ExUnit.Case

  test "Unknown type module raises an error" do
    assert_raise RuntimeError, ~r/Invalid data type «:unknown»/, fn ->
      defmodule A do
        use DD
        defrecord do
          unknown(:name)
        end
      end
    end
  end

  test "Suspicious type module raises an error" do
    assert_raise RuntimeError, ~r/Invalid data type «:isnt»/, fn ->
      defmodule B do
        use DD
        defrecord do
          isnt(:name)
        end
      end
    end
  end
  
end
