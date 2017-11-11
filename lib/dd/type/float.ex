defmodule DD.Type.Float do

  ########################################
  @behaviour DD.Type.Behaviour
  ########################################

  def from_options(_name, spec) do
    spec |> valid_options()
  end
  

  def validate(value, specs) when is_binary(value) do
    try do
      to_float(value)
      |> validate(specs)
    rescue
      ArgumentError ->
        { "%{value} should be a float", value: inspect(value) }
    end
  end
  

  def validate(value, specs) when is_number(value) do
    validate_range(value, specs[:min], specs[:max])
  end

  def validate(value, _) do
    { "%{value} should be a float", value: inspect(value) }
  end
  
  def to_display_value(value, _) do
    value
  end

  # if the conversion fails, pass in whatever we have, because
  # validation will catch it
  def from_display_value(value, _options) when is_integer(value) do
    value + 0.0
  end
  
  def from_display_value(value, _options) when is_binary(value) do
    try do
      to_float(value)
    rescue
      ArgumentError ->
        value
    end
  end

  def from_display_value(value, _options) do
   value
  end




  
  ##########
  # range #
  ##########
  
  defp validate_range(_value, nil, nil), do: nil

  defp validate_range(value, min, max) do
    cond do
      min && value < min ->
        {
          "must be at least %{min} (currently %{value})",
          min: min, value: value
        }
      max && value > max ->
        {
          "cannot be greater than %{max} (currently %{value})",
          max: max, value: value
        }
      true ->
        nil
    end
  end

  ###################
  # Option handling #
  ###################

  defp valid_options(options) do
    options
    |> Enum.map(&valid_option/1)
  end
    
  defp valid_option({:min, n}) when is_number(n) and n >= 0 do
    { :min, to_float(n) }
  end
  
  defp valid_option({:max, n}) when is_number(n) and n >= 0 do
    { :max, to_float(n) }
  end

  defp valid_option({name, value}) do
    DD.Type.valid_option({name, value})
  end


  defp to_float(value) when is_float(value),   do: value
  defp to_float(value) when is_integer(value), do: value + 0.0
  defp to_float(value) when is_binary(value) do
    try do
      String.to_float(value)
    rescue
      ArgumentError ->
        String.to_integer(value) + 0.0
    end
  end
  
  defp to_float(value) do
    raise ArgumentError, "#{inspect value} can't be represented as a float"
  end
  
end
