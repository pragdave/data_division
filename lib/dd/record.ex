defmodule DD.Record do

  def from(module, new_values) do
    values =
      module.__defaults
      |> Map.merge(atomize_keys(new_values) |> to_map)

    IO.puts "\n\n*****convert from external to internal*****\n\n"

    
    module.__blank_record
    |> Map.put(:values, values)
    |> Map.put(:fields, module.__fields)
    |> DD.Validate.update_errors(module)
  end

  def hidden_fields(module) do
    module.__fields()
    |> Enum.filter(fn {name, defn} -> defn.options[:hidden] end)
    |> Enum.map(&elem(&1, 0))
  end

  ############################################################

  defp to_map(new_values) when is_map(new_values) do
    new_values
  end
  
  defp to_map(new_values) do
    new_values |> Enum.into(%{})
  end

  defp atomize_keys(map) do
    map
    |> Enum.map(&atomize_key/1)
    |> Enum.into(%{})
  end

  defp atomize_key(pair = {k, v}) when is_atom(k), do: pair

  defp atomize_key({k, v}), do: {String.to_atom(k), v}


end
