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
                      show_as: { ~w/y yes sure/, ~w/n no nope/ }
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
