ExUnit.start()

defmodule DD.TestHelpers do

  use ExUnit.Case
  
  def error(msg), do: { msg, [] }

  def assert_errors(%{ errors: errors }, expected) do
    assert(
      Keyword.keys(errors) == Keyword.keys(expected),
      "checking error keys"
    )
    
    for { field, { msg, values }} <- errors do
      { expected_msg, expected_values } = expected[field]
      unless String.contains?(msg, expected_msg) do
        flunk("expected #{inspect msg} to contain #{inspect expected_msg}")
      end
      assert values == expected_values
    end
  end
end
