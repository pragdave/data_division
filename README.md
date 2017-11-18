# Data Division

A library that generates data-holding structures with validation,
error maps, and compatibility with Phoenix `form_for`.


### Let's Get Started

1. Add the dependency:

       def deps() do
         [
           :data_division, ">= 0.0.0",
           . . .
        ]
        
2. Define the fields in the structure:

        defmodule Planet do
          use DD
          
          deffieldset do
            string :name,      min: 4
            float  :mass
            bool   :habitable, default: false
            int    :moon_count
          end
        end

3. Create and populate structures based on this structure:

       neptune = Planet.new(
           name:       "Neptune", 
           mass:       1.024e26, 
           moon_count: 14)
           
4. They found another moon:

       new_neptune = neptune |> Planet.update(moon_count: 15)
       
5. Is the structure valid? If not, what are the errors?

       if !Planet.valid?(neptune) do
         for { field, error_msg } <- neptune.errors do
           IO.puts "#{field}: #{error_msg}"
         end
       end

6. Let's use it in Phoenix:

   controller action:
   
       render conn, "edit.html", planet: neptune
       
   template:
   
       <%= form_for @planet, ..... 


## Why?

If you want to use Phoenix forms to create and update data accessed
using Ecto, then you have to have ecto running in the Phoenix
application.

That's not how I want to design applications. I want my business logic
in its own applications, and I want Phoenix to be one of potentially
many frontends to it.

For example, an online store might perform overnight accounting
functions. These functions will want to use the same business logic
used by the store (for example, to access orders), but it doesn't have
a web UI. The accounting code should be able to make the same calls
into the business layer as the frontend, but without having the
frontend in the middle.

The Data Division library lets you do this. It lets you define things
that are like Ecto schemas, and populate from from an Ecto changeset.

You can then pass the result to other applications that are not
running Ecto. Because a Data Division fieldset implements the Phoenix
`Form.Data` protocol, you can use them with Phoenix forms.

The net result is that you can decouple presentation from business
logic.



## deffieldset

`deffieldset` is a bit like Ecto's `schema`. It defines a struct that
contains a place for data (like the planet information above) and a
place for metadata on field types, options, and so on.

It should be used in a module, just like `defstruct`:

        defmodule Planet do
          use DD
          
          deffieldset do
            string :name,      min: 4
            float  :mass,      min: 0.0
            bool   :habitable, default: false
            int    :moon_count
          end
        end
    
This code defines a structure called `Planet` with 4 fields. Each field
definition starts with the field type, followed by the field name (an
atom). The rest depends to some extent on the type of the field,
although all fields support default values.

In this example, the `name` field has a validation: it must be at
least 4 characters long. Similarly the `mass` field has a validation:
it cannot be less that zero. Note that although the option is named
the same in both cases `min:`) its interpretation depends on the field
type: for strings it is the length, for floats the value.

A list of the available types and their options is [below](#types).

## Using the Fields

You create new instances of a structure using
_Name_.`new(values)`. The `values` you pass in can be a keyword
list, map, or struct. If `values` is a struct of type
`Ecto.Changeset`, then values and errors are copied directly from it
into the record.


`new` returns a structure containing three entries:

* `values`

  A map, keyed by the field name, containing that fields current
  value.
  
* `errors`

  A map, keyed by the field name. If an entry exists for a field, its
  value is the _first validation error_ associated with that field. 
  
* `fields`

  A reference to a field definition structure
  

So, we could do something like:

       neptune = Planet.new(
           name: "Neptune", 
           moon_count: 14)
           
       IO.inspect neptune.errors     #=> %{ mass: "must be present" }
       
       neptune = Planet.update(neptune, mass: 1.024e26
       
       IO.inspect neptune.errors     #=> %{ }
       IO.inspect neptune.valid?     #=> true
       
       
## Built-in Types

* All types accept the options:

  * `default:` _a type appropriate value_
  
  * `optional:` _defaults to `true` unless a default was provided
  
    In this world, an optional field is one that may have a nil value.
    Think of it as corresponding to the database `not null`
    constraint.

  * `validate_with:` _a Module or a function_ (or a list of them)
  
    See _Custom Validations_ below.
    
    Note that validation for a particular field stops on the first
    validation failure—once a field has been found to be invalid,
    no more checks are done on that particular field.

* (`string`)[...]`:`_name_

  Options:
  
  * `min:` _min_length_
  * `max:` _max_length_
  * `matches:` _string_ or _regex_

  Conversion:
  
  * incoming values: nonstrings are converted using inspect
  * outgoing values: none

* (`int`)[...]`:`_name_

  Options:
  
  * `min:` _min_value_
  * `max:` _max_value_

  Conversion:
  
  * incoming values: incoming strings are converted using
    `String.to_integer`
  * outgoing values: none

* (`float`)[...]`:`_name_

  Options:
  
  * `min:` _min_value_
  * `max:` _max_value_

  Conversion:
  
  * incoming values: incoming strings are converted using
    `String.to_float` or `String.to_integer`. Incoming integers are
    converted by adding `0.0`
  * outgoing values: none

* (`bool`)[...]`:`_name_

  Options:
  
  * `show_as` _{ true-values, false-values }__

    `true-values` is a string or a list of strings. It this field is 
    set to one of these, it will have an internal value of `true`. `false-values` work the same way for `false`.
    
    If not specified, `show_as:` defaults to `[ "true", "false" ]`.

  Conversion:
  
  * incoming values: incoming strings are converted using
    `show_as:` to either true or false.
  * outgoing values: the first true or false value in `ahow_as:`
    is used.

* etc  

### Custom Validations

You can define your own field validators. Each is a function that takes a 
value and returns either 

    nil
    
if the value is valid, or

    { msg_with_placeholders, p1: v1, … }
    
if it is invalid. In the latter case the first field in the returned
tuple is a string containing optional placeholders. The values that
are to be substituted for each placeholder are given in the subsequent
keyword list:

    { "%{value} must have exactly %{n} factors", value: 30, n: 2 }
    
Add a custom validator to a field using the `validate_with:` option.
This takes either a single validator or a list of validators.

If a validator is the name of a module, then the field is validted by
calling the function `validate/1` in that module.

If a validator is a function, then it is called withe the value to
validate.

For example:

    # This is a validation module
    defmodule EvenValidator do
      require Integer
      def validate(value) when Integer.is_even(value), do: nil
      def validate(_), do: { "must be even..", [] }
    end

    # and this module contains validation functions
    defmodule Validations do
      require Integer
      def is_even(value) when Integer.is_even(value), do: nil
      def is_even(_), do: { "must be even!!", [] }
    end
    

    defmodule A do
      use DD
      deffieldset do
        int(:even1, default: 2, validate_with: EvenValidator)
        int(:even2, default: 2, validate_with: &Validations.is_even/1)
      end
    end


## Adding Your Own Types

A type is simply an Elixir module that:

1. is named `DD.Type.YourType`

2. uses the behaviour `DD.Type.Behaviour`

3. implements the handful of functions required by that behaviour.

If this module is loaded into your project, then the type becomes
available in `deffieldset` as if it was a function named using the
lowercase form of the last part of the module name. So, in this
example, you could have

   deffieldset do
     string(:name)
     your_type(:orbit_parameters)
   end
   
See the module doc for [Data.Type](,,,) for details.
   
       

## Working with Ecto

The `MyFieldset.new/1` function normally takes a map, struct, or
keyword list containing key value pairs. It copies the values into the
fieldset, then performs validations and sets any errors.

You can also pass it an Ecto changeset. In this case, it copies the
values from the changeset data, and copies the errors from the
changeset errors. 

### ToDo: add support for `deffieldset based_on My.Schema`

