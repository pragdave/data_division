defmodule DD.Impl do
  
  defmacro defrecord(do: field_list) do

    field_list = normalize_field_list(field_list)

    defaults =
      field_list
      |> Code.eval_quoted
      |> elem(0)
      |> Enum.map(fn { name, rest } -> { name, rest.options[:default] } end)
      |> Enum.filter(fn {_name, default} -> default end)
      |> Enum.into(%{})
    
      |> IO.inspect
      
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
    type_module.from_spec(name, options)
  end
  
end
