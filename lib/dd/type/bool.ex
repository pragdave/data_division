defmodule DD.Type.Bool do

  ########################################
  @behaviour DD.Type.Behaviour
  ########################################

  def from_options(_name, spec) do
    [ show_as: { "true", "false" } ]
    |> Keyword.merge(spec)
    |> valid_options()
  end
  

  def validate(true, _), do: nil
  def validate(false, _), do: nil
  def validate(other, _) do
    { "%{other} should be a boolean", [ other: inspect(other) ] }
  end


  # choose the first of the available options
  def to_display_value(value, options) when value do
    options[:show_as] |> elem(0) |> hd
  end

  def to_display_value(_value, options) do
    options[:show_as] |> elem(1) |> hd
  end

  # Find the value in the lists of true or false

  
  def from_display_value(true, _),  do: true
  def from_display_value(false, _), do: false
  
  def from_display_value(value, options) do
    cond do
      value in elem(options[:show_as], 0) ->
        true
      value in elem(options[:show_as], 1) ->
        false
      true ->
        value
    end
  end




  

  ###################
  # Option handling #
  ###################

  defp valid_options(options) do
    options
    |> Enum.map(&valid_option/1)
  end

  defp valid_option({:show_as, {trues, falses}})
    when is_list(trues) and is_list(falses) do
      {:show_as, {trues, falses}}
  end
  
  defp valid_option({:show_as, {trues, falses}})
    when is_binary(trues) do
      valid_option({:show_as, {[trues], falses}})
  end
  
  defp valid_option({:show_as, {trues, falses}})
    when is_binary(falses) do
      valid_option({:show_as, {trues, [falses]}})
  end
  
  defp valid_option({name, value}) do
    DD.Type.valid_option({name, value})
  end
end
