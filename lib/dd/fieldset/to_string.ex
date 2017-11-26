defmodule DD.FieldSet.ToString do

  alias Inspect.Algebra, as: IA

  # TODO: "format these properly"
  
  def to_string(record) do
    values_to_string(record)
    |> IA.format(80)
    |> IO.iodata_to_binary
  end

  defp values_to_string(%{ fields: fields, values: values }) do
    IA.container_doc("\n", values |> Map.to_list, "\n",
      %Inspect.Opts{},
      fn {k, v}, _ ->
        IA.glue(Atom.to_string(k), ": ", value_to_string(v, fields[k]))
      end)
  end

  defp value_to_string(value, _field_spec = %{ type: type, options: options}) do
    type.to_display_value(value, options)
  end

end
