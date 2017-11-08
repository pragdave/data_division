defmodule A do
  use DD
  defrecord do
    string(:f1)
    string(:f2, default: "val", max: 4)
  end
end

defmodule DDTest do
  use ExUnit.Case
  doctest DD


  test "Defaults are copied into an empty field" do
    with result = A.new_record(f1: "some") do
      assert result.errors == [ ]
      assert result.values == %{ f1: "some", f2: "val" }
    end
  end

  test "Defaults can be overridden" do
    with result = A.new_record(f1: "some", f2: "body") do
      assert result.errors == [ ]
      assert result.values == %{ f1: "some", f2: "body" }
    end
  end


  test "a field without a default value must be explicitly given" do
    with result = A.new_record(f2: "body") do
      assert result.errors == [ f1: { "requires a value", [] } ]
    end
  end
end
