defmodule DD.Validate do

  def update_errors(record, module) do
    %{ record | errors: errors_for(record, module) }
  end

  defp errors_for(record, module) do
    errors_for_each_field(record, module)
    |> remove_entries_for_fields_with_no_errors()
  end

  defp errors_for_each_field(record, module) do
    module.__fields
    |> Enum.reduce({ record, [] }, &errors_for_one_field/2)
    |> elem(1)
  end

  defp remove_entries_for_fields_with_no_errors(errors) do
    errors
    |> Enum.filter(fn { _, error } -> error end)
  end


  defp errors_for_one_field({name, defn}, accum = { record, result }) do
    value = record.values[name]
    optional = defn.options[:optional]

    # if a field is optional, then nil is always valid
    if value == nil && optional do
      accum
    else
      error =
        cross_type_validations(value, defn.options) ||
        type_specific_validations(defn.type, value, defn.options) ||
        custom_validators(value, defn.options[:validate_with])
    
      { record, [ { name, error } | result ] }
    end
  end


  ####################################
  #  Validations common to all types #
  ####################################
  
  defp cross_type_validations(value, specs) do
    validate_present(value, specs[:optional])
  end

  defp validate_present(_value, optional) when optional do
  end

  defp validate_present(value, _optional) do
    if value == nil || value == "" do
      { "requires a value", [] }
    else
      nil
    end
  end

  ###################################################################
  # Custom validations. The validator can be a module (implementing #
  # `validate(value)` or a function.                                #
  ###################################################################

  defp custom_validators(_value, nil) do
    nil
  end

  defp custom_validators(value, [ validator | rest ]) do
    custom_validators(value, validator) || custom_validators(value, rest)
  end  

  defp custom_validators(_value, []) do
    nil
  end  
  
  defp custom_validators(value, validator) when is_atom(validator) do
    validator.validate(value)
  end

  defp custom_validators(value, validator) when is_function(validator) do
    validator.(value)
  end

  defp custom_validators(_value, other) do
    raise """
    validate_with: #{inspect other} is not valid. It expects to
    receive a module implementing `validate/1` or a function.
    """
  end

  #########################################
  # Dispatch to type-specific validations #
  #########################################

  defp type_specific_validations(type, value, specs) do
    type.validate(value, specs)
  end
end
