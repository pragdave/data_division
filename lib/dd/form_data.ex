Code.ensure_loaded?(Phoenix.HTML) &&

defmodule DD.FormData do 

  @moduledoc """

  This is an implementation of Phoenix's FormData protocol, but done as a mixin.

  Although the FormData protocol is documented at the API level, there's no real
  explanation of how it is used.

  This is cobbled together based on code reading and trial and error.

  ### Flow

  You pass Phoenix.HTML.form_for a data holder as its first parameter. This
  can be am ecto changeset, a connection value, or anything else that implements 
  Phoenix.HTML.FormData.

  #### `to_form`

  `form_for` starts by calling the `to_form` function in the module corresponding
  to the struct you pass in, passing it the data holder and the form_for options.

  `to_form` should return a `Phoenix.HTML.Form` structure:


  """


  def to_form(record, opts) do

    ## %{params: params, data: data} = changeset
    {name, opts} = Keyword.pop(opts, :as)
    name = to_string(name || form_for_name(record))

    %Phoenix.HTML.Form{
      source:  record,
      impl:    __MODULE__,
      id:      name,
      name:    name,
      errors:  record.errors,
      data:    record.values,
      params:  %{},
      hidden:  form_for_hidden(record),
      options: Keyword.put_new(opts, :method, form_for_method(record))
    }
  end

  def to_form(a, b, c, d) do
    IO.puts "to_form/2 #{inspect [a,b,c,d]}"
  end

  def input_value(%{fields: fields, values: values}, %{params: params}, field, computed \\ nil) do
    field_spec = fields[field]

    case Map.fetch(values, field) do
      {:ok, value} ->
        value
      :error ->
        case Map.fetch(params, Atom.to_string(field)) do
          {:ok, value} ->
            value
          :error ->
            computed
        end
    end
    |> field_spec.type.to_display_value()
  end

  def input_type(%{types: types}, _, field) do
    IO.puts "input type #{inspect field}"
    # type = Map.get(types, field, :string)
    # type = if Ecto.Type.primitive?(type), do: type, else: type.type
    # 
      # case type do
      #   :integer        -> :number_input
      #   :float          -> :number_input
      #   :decimal        -> :number_input
      #   :boolean        -> :checkbox
      #   :date           -> :date_select
      #   :time           -> :time_select
      #   :utc_datetime   -> :datetime_select
      #   :naive_datetime -> :datetime_select
    #   _               -> :text_input
    # end
  end

  def input_validations(%{required: required, validations: validations} = changeset, _, field) do

    IO.puts "input validations #{inspect field}"
  end
  defp form_for_hidden(record = %{__struct__: module}) do
    DD.Record.hidden_fields(module)
    |> Enum.map(fn name -> { name, record.values[name] } end)
  end

  defp form_for_name(%{__struct__: module}) do
    module
    |> Module.split()
    |> List.last()
    |> Macro.underscore()
  end

  defp form_for_name(record) do
    raise ArgumentError, "can't find the form name for the record #{inspect record}"
  end

  defp form_for_method(record) do
    if hidden_fields_present_and_have_values(record), do: "put", else: "post"
  end

  defp hidden_fields_present_and_have_values(record = %{__struct__: module}) do
    IO.puts "passing #{module} to hidden"
    DD.Record.hidden_fields(module)
    |> check_hiddens_fields_present(record)
  end

  defp check_hiddens_fields_present([], _) do
    false
  end

  defp check_hiddens_fields_present(fields, record) do
    fields
    |> Enum.all?(fn name -> record.values[name] end)
  end

end
