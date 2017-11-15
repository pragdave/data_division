defmodule DDBoolTest do
  use ExUnit.Case

  import DD.TestHelpers

  
  ####################### fixtures ###########################
  
  defmodule Basic do
    use DD
    defrecord do
      bool :is_true,  default: true
      bool :is_false, default: false
      bool :yes_no,   default: true,  show_as: { "yes", "no" }
      bool :tick_x,   default: false, show_as: { "✓", "✖" }
      bool :multi_yn, default: true,
                      show_as: { ~w/yes y sure/, ~w/no n nope/ }
    end
  end

   
  defmodule BadDefault do
    use DD
    defrecord do
      bool(:f1, default: "wombat")
    end
  end

  ###################### tests ###############################
  
  test "Basic bool works" do
    with result = Basic.new_record() do
      assert result.errors == []
      assert result.values.is_true  === true
      assert result.values.is_false === false
    end
  end

  
  test "A record with an invalid default is marked in error" do
    with result = BadDefault.new_record() do
      assert_errors(result,
        f1: {
          "should be a boolean",
          other: ~s/"wombat"/
        }
      )
    end
  end

  test "the show_as list is used when setting a field" do
    with result = Basic.new_record(yes_no: "yes") do
      assert result.errors == []
      assert result.values.yes_no  === true
    end
    with result = Basic.new_record(yes_no: "no") do
      assert result.errors == []
      assert result.values.yes_no  === false
    end
  end

  test "any element in  show_as list can be used" do
    [
      { "y", true },
      { "n", false },
      { "yes", true },
      { "no",  false },
      { "sure", true },
      { "nope", false }
    ]
    |> Enum.map(fn {input, expected} ->
      result = Basic.new_record(multi_yn: input)
      assert result.values.multi_yn === expected, input
    end)
  end

  test "the first element of a show_as list is used as a display value" do
    result = Basic.new_record(multi_yn: true)
    assert to_string(result) =~ ~r/multi_yn:\s+yes/

    result = Basic.new_record(multi_yn: false)
    assert to_string(result) =~ ~r/multi_yn:\s+no/

  end
  
end
