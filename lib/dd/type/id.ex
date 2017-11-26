defmodule DD.Type.Id do

  ########################################
  @behaviour DD.Type.Behaviour
  ########################################

  def from_options(_name, spec) do
    [ hidden: true, optional: true ]
    |> Keyword.merge(spec)
    |> valid_options()
  end
  

  def validate(_, _) do
    nil
  end
  
  def to_display_value(value, _spec) do
    value |> inspect()
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
