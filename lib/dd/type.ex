defmodule DD.Type.Behaviour do


  @doc """
  A record is defined using something like

        defrecord Person do
          string(:name, min: 2, max: 50)
          date(:dob)
        end

  The `defrecord` code calls the type module's `from_spec` function
  for each field (so the type modules DD.Type.String and 
  DD.Type.Date would be called about).

  This function returns a field definition structure, having first
  validated (and possibly manipulated) the arguments.

  In the first example above, `from_spec` would we called with

      DD.String.from_options(:name, [ min: 2, max: 50 ])

  Values that are stored in the field structure have potentially been
  updated to work with this type. For example, if you pass a string as
  an option to DD.Type.String's `matches:` option, it will be returned
  as a Regex.

  """

  @callback from_options(atom(), keyword()) :: { module(), atom(), Keyword.t }

  
  

  @doc """
  Convert a value to a string that will be suitable for display (for
  example as the value of an <input> tag.
  """
  @callback to_display_value(Any.t, Keyword.t) :: String.t

  @doc """
  Convert a string external representation of a value into into
  it's internal representation
  """
  @callback from_display_value(String.t, Keyword.t) :: Any.t

  
  @doc """
  Validates that the given value is consistent with a type and
  that it obeys any constraints in it's specs.

  For example, the validation for DD.Type.String is:

  ~~~ elixir
  def validate(value, _) when not is_binary(value) do
    "should be a string"
  end

  def validate(value, specs) do
    validate_length(String.length(value), specs[:min], specs[:max])
    || validate_matches(value, specs[:matches])
  end
  ~~~

  """
  @callback validate(Any.t, Access.t)  :: String.t | nil
  
end

defmodule DD.Type do

  def find_definition(type) do
    type
    |> type_module()
    |> check_module_valid(type)
  end

  def valid_option(spec = {option_name, _})
    when option_name in [ :default, :optional, :opt, :validate_with ] do
    spec
  end

  def valid_option({name, value}) do
    raise """
    Invalid constraint:

        #{name}:  #{inspect value}
    """
  end
  

  defp type_module(type) do
    type
    |> Atom.to_string
    |> String.capitalize
    |> String.to_atom
    |> (&[Elixir, DD, Type, &1]).()
    |> Module.concat
  end

  defp check_module_valid(module, type) do
    case Code.ensure_loaded(module) do
      { :error, _ } ->
        raise """
           Invalid data type «#{inspect type}». 
           Module #{inspect module} doesn't exist."
           """
      _ ->
        nil
    end
    case function_exported?(module, :from_options, 2) do
      true ->
        module
      _ ->
        raise """
           Invalid data type «#{inspect type}». 
           Module #{inspect module} doesn't define `from_options/2`.
           """
    end
  end

end
