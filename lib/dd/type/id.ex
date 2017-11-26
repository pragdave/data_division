defmodule DD.Type.Id do

  ########################################
  @behaviour DD.Type.Behaviour
  ########################################

  def from_options(_name, spec) do
    [ hidden: true, optional: true ]
    |> Keyword.merge(spec)
    |> valid_options()
  end
  

  def validate(value, specs) when is_binary(value) do
    try do
      String.to_integer(value)
      |> validate(specs)
    rescue
      ArgumentError ->
        { "%{value} should be an integer", value: inspect(value) }
    end
  end
  
  def validate(value, _) do
    { "%{value} should be an integer", value: inspect(value) }
  end
  
  def to_display_value(value, _spec) do
    value |> to_string()
  end

  # if the conversion fails, pass in whatever we have, because
  # validation will catch it
  def from_display_value(value, _options)  when is_binary(value) do
    try do
      String.to_integer(value)
    rescue
      ArgumentError ->
        value
    end
  end

  def from_display_value(value, _options) do
   value
  end


  ###################
  # Option handling #
  ###################

  defp valid_options(options) do
    options
    |> Enum.map(&valid_option/1)
  end

  defp valid_option({:hidden, value}) do
    {:hidden, value}
  end
  
  defp valid_option({name, value}) do
    DD.Type.valid_option({name, value})
  end
end
