defmodule DD.Impl do
  
  defmacro defrecord(do: field_list) do

    field_list = normalize_field_list(field_list)

    defaults = extract_defaults_from(field_list)

    quote do
      try do

        @__fields unquote(field_list)
        def __fields(), do: @__fields

        def __defaults(), do: unquote(Macro.escape(defaults))
        
      after
        :ok
      end
    end
       

  end

  defimpl(Phoenix.HTML.FormData, for: Any) do
    defdelegate to_form(record, opts),                to: DD.FormData
    defdelegate to_form(record, a, b, opts),          to: DD.FormData
    defdelegate input_validations(data, form, field), to: DD.FormData
    defdelegate input_value(data, form, field),       to: DD.FormData
    defdelegate input_type(data, form, field),        to: DD.FormData
  end
    
  
  defmacro __using__(_) do
    quote do
      require Protocol
      
      import DD.Impl, only: [ defrecord: 1 ]
      
      defstruct values: nil, errors: %{}, fields: %{}

      Protocol.derive(Phoenix.HTML.FormData, __MODULE__)

      def __blank_record, do: %__MODULE__{}
      
      def new_record(values \\ []) do
        DD.Record.from(__MODULE__, values)
      end

      def update(values) do
      end

      def valid?(%{ errors: %{}}), do: true
      def valid?(_),               do: false
    end
  end


  defp normalize_field_list({:__block__, context, fields}) do
      fields
      |> Enum.map(&convert_one_field/1)
  end

  
  defp normalize_field_list(field = {_type, _context, _args}) do
    [ convert_one_field(field) ]
  end

  defp convert_one_field({type, context, [ name ]}) do
    convert_one_field({type, context, [ name, [] ]})
  end

  defp convert_one_field({type, context, [ name, spec ]})
  when is_atom(name) and is_list(spec) do
    type_module = DD.Type.find_definition(type)
    {options, _} = spec |> Code.eval_quoted(spec)
    spec = type_module.from_options(name, options)
    quote do
      {
        unquote(name),
        %{
          type:    unquote(type_module),
          options: unquote(spec |> Macro.escape)
        }
      }
    end

  end


  # World's ugliest function. We take the list of fields,
  # which is quoted code. We evaluation it to get a list of fields
  # as terms. These look like
  #
  #    { name, {type: type, options: options }}
  #
  # We extract the name, type, and default value, eliminate
  # fields with no default, run that default through the
  # type-specific external-to-internal convertor, then
  # return a map of { name, internal_default} values.
  
  defp extract_defaults_from(field_list) do
    field_list
      |> Code.eval_quoted
      |> elem(0)
      |> Enum.map(fn { name, rest } ->
        { name, rest.type, rest.options[:default] }
      end)
      |> Enum.filter(fn {_name, type, default } ->
        default
      end)
      |> Enum.map(fn { name, type, default } ->
        { name, type.from_display_value(default) }
      end)
      |> Enum.into(%{})
  end
  
end
