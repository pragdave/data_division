defmodule EvenValidator do
  require Integer
  def validate(value) when Integer.is_even(value), do: nil
  def validate(_), do: { "must be even..", [] }
end


defmodule Validations do
  require Integer
  def is_even(value) when Integer.is_even(value), do: nil
  def is_even(_), do: { "must be even!!", [] }

  def multiple_of_3(value) do
    case rem(value, 3) do
      0 ->
        nil
      _ ->
        { "%{value} is not a multiple of 3", value: value }
    end
  end
  
  def multiple_of_5(value) do
    case rem(value, 5) do
      0 ->
        nil
      _ ->
        { "%{value} is not a multiple of 5", value: value }
    end
  end
  
end

defmodule DD.CustomValidationTest do
  use ExUnit.Case
  import DD.TestHelpers

  describe "basic custom validators" do
    defmodule A do
      use DD
      
      defrecord do
        int(:even1, default: 2, validate_with: EvenValidator)
        int(:even2, default: 2, validate_with: &Validations.is_even/1)
      end
    end

    test "with no errors" do
      result = A.new_record()
      assert result.errors == []
      assert result.values.even1 == 2
      assert result.values.even2 == 2
    end

    test "using module" do
      result = A.new_record(even1: 3)
      assert_errors(result, even1: {"must be even..", []})
    end

    test "using function" do
      result = A.new_record(even2: 3)
      assert_errors(result, even2: {"must be even!!", []})
    end
  end


  
  describe "list of validators" do
    defmodule B do
      use DD
      
      defrecord do
        int(:fizzbuzz, validate_with: [
              &Validations.multiple_of_3/1,
              &Validations.multiple_of_5/1
            ])
      end
    end

    test "with no errors" do
      result = B.new_record(fizzbuzz: 15)
      assert result.errors == []
      assert result.values.fizzbuzz == 15
    end

    test "with error on last" do
      result = B.new_record(fizzbuzz: 3)
      assert_errors(result, fizzbuzz: {"is not a multiple of 5", value: 3})
    end


    test "with error on first" do 
      result = B.new_record(fizzbuzz: 5)
      assert_errors(result, fizzbuzz: {"is not a multiple of 3", value: 5})
    end

    test "with error on both only returns first" do 
      result = B.new_record(fizzbuzz: 7)
      assert_errors(result, fizzbuzz: {"is not a multiple of 3", value: 7})
    end
  end

  test "invalid validators are detected 1" do
    defmodule C do
      use DD
      defrecord do
        string(:a, validate_with: Wombat)
      end
    end
    assert_raise(RuntimeError, ~r/validate_with: Wombat/, fn ->
      C.new_record(a: "ccc")
    end)
  end

  test "invalid validators are detected 2" do
    defmodule C do
      use DD
      defrecord do
        string(:a, validate_with: 123)
      end
    end
    assert_raise(RuntimeError, ~r/validate_with: 123/, fn ->
      C.new_record(a: "ccc")
    end)
  end

end
