defmodule DDTest do
  use ExUnit.Case
  doctest DD

  import DD.TestHelpers

  describe "defaults:" do

    defmodule A do
      use DD
      defrecord do
        string(:f1)
        string(:f2, default: "val", max: 4)
      end
    end

    test "are copied into an empty field" do
      with result = A.new_record(f1: "some") do
        assert result.errors == [ ]
        assert result.values == %{ f1: "some", f2: "val" }
      end
    end

    test "can be overridden" do
      with result = A.new_record(f1: "some", f2: "body") do
        assert result.errors == [ ]
        assert result.values == %{ f1: "some", f2: "body" }
      end
    end


    test "missing means a field if required" do
      with result = A.new_record(f2: "body") do
        assert result.errors == [ f1: { "requires a value", [] } ]
      end
    end
  end
  
  describe "fields" do

    defmodule B do
      use DD
      
      defrecord do
        string :required
        string :required_but_defaulted, default: "hello"
        string :optional, optional: true
        string :opt, opt: true
      end
    end


    test "that are optional and required are handled" do
      with result = B.new_record(required: "xxx") do
        assert result.errors == [ ]
        assert result.values.required == "xxx"
        assert result.values.optional == nil
        assert result.values.opt == nil
      end
    end

    test "that are required don't validate if missing" do
      with result = B.new_record() do
        assert result.errors == [ required: {"requires a value", []}]
      end
    end
  end

  describe "update" do
    defmodule C do
      use DD
      defrecord do
        string(:f1, min: 3, max: 5)
      end
    end

    test "works on a simple record" do
      result = C.new_record(f1: "cat") 
      assert result.errors == []
      assert result.values.f1 == "cat"
      result = C.update(result, f1: "dog")
      assert result.errors == []
      assert result.values.f1 == "dog"
    end

    test "validates the update" do
      result = C.new_record(f1: "cat") 
      assert result.errors == []
      assert result.values.f1 == "cat"
      result = C.update(result, f1: "doggie")
      assert_errors(result,
        f1: { "cannot be longer than", max: 5, length: 6 })
    end
  end
  
end
