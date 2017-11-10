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
    |> Enum.filter(fn { _, {error, _opts} } -> error end)
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
        type_specific_validations(defn.type, value, defn.options)
    
      { record, [ { name, { error, [] } } | result ] }
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

  defp validate_present(value, optional) do
    if value == nil || value == "" do
      "requires a value"
    else
      nil
    end
  end

  #########################################
  # Dispatch to type-specific validations #
  #########################################

  defp type_specific_validations(type, value, specs) do
    type.validate(value, specs)
  end
end
