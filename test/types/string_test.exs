  
defmodule DDStringTest do
  use ExUnit.Case

  ####################### fixtures ###########################
  
  defmodule A do
    use DD
    defrecord do
      string(:f1, default: "123")
      string(:f2, default: "123", min: 2)
      string(:f3, default: "123", max: 4)
      string(:f4, default: "123", min: 2, max: 4)
      string(:f5, default: "123", matches: ~r{2})
    end
  end
  
  defmodule BadDefault do
    use DD
    defrecord do
      string(:f1, default: 99)
    end
  end

  ###################### tests ###############################
  
  test "Default values have no errors" do
    with result = A.new_record() do
      assert result.errors == []
    end
  end

  test "Minimum length checked" do
    with result = A.new_record(f2: "a") do
      assert result.errors == [f2: error("must be at least 2 characters long  (its length is 1)")]

    end
  end

  test "Maximum length checked" do
    with result = A.new_record(f3: "abcde") do
      assert result.errors == [ f3: error("cannot be longer than 4 characters (its length is 5)") ]
    end
  end

  test "Regex matches" do
    with result = A.new_record(f5: "abc") do
      assert result.errors == [ f5: error("must match the pattern ~r/2/") ]
    end
  end

  test "A record with an invalid default is marked in error" do
    with result = BadDefault.new_record() do
      assert result.errors ==  [ f1: error("should be a string") ]
    end
  end

  test "good options are accepted" do
    alias DD.Type.String, as: DTS

    [
      pass_expect([]),

      # global options
      
      pass_expect(default: 99),

    # string options
      
      pass_expect(min: 3, max: 5),
      pass_expect(matches: ~r/123/),

      # string in match is converted to a Regex
      
      pass_expect([matches: "123"], [matches: ~r/123/]),
    ]
    |> IO.inspect
    |> Enum.each(fn { pass, expect } ->
      {{_name, %{ options: options, type: type}}, _} =
        DTS.from_spec(:name, pass) |> Code.eval_quoted
      
      assert options == expect
      assert type == DTS
      end)
  end

  test "bad options are rejected" do
    alias DD.Type.String, as: DTS

    [
      [ wombat: 99 ],
      [ min: -1 ],
      [ min: "cow" ],
      [ max: -1 ],
    ]
    |> Enum.each(fn option ->
         assert_raise(RuntimeError, ~r/Invalid constraint:/, fn ->
           DTS.from_spec(:name, option)
         end)
      end)
  end

  defp pass_expect(opts), do: { opts, opts }
  
  defp pass_expect(pass, expect), do: { pass, expect }

  defp error(msg), do: { msg, [] }
end
