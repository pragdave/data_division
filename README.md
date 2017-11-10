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
        
2. Define a record structure:

        defmodule Planet do
          use DD
          
          defrecord do
            string :name,      min: 4
            float  :mass
            bool   :habitable, default: false
            int    :moon_count
          end
        end

3. Create and populate structures based on this record:

       neptune = Planet.new_record(
           name:       "Neptune", 
           mass:       1.024e26, 
           moon_count: 14)
           
4. They found another moon:

       new_neptune = neptune |> Planet.update(moon_count: 15)
       
5. Is the record valid? If not, what are the errors?

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
       
## defrecord

`defrecord` is a bit like Ecto's `schema`. It defines a struct that
contains a place for data (like the planet information above) and a
place for metadata on field types, options, and so on.

It should be used in a module, just like `defstruct`:

        defmodule Planet do
          use DD
          
          defrecord do
            string :name,      min: 4
            float  :mass,      min: 0.0
            bool   :habitable, default: false
            int    :moon_count
          end
        end
    
This code defines a record called `Planet` with 4 fields. Each field
definition starts with the field type, followed by the field name (an
atom). The rest depends to some extent on the type of the field,
although all fields support default values.

In this example, the `name` field has a validation: it must be at
least 4 characters long. Similarly the `mass` field has a validation:
it cannot be less that zero. Note that although the option is named
the same in both cases `min:`) its interpretation depends on the field
type: for strings it is the length, for floats the value.

A list of the available types and their options is [below](#types).

## Using a Record

You create new instances of a record using
_Name_.`new_record(values)`.

This returns a structure containing three entries:

* `values`

  A map, keyed by the field name, containing that fields current
  value.
  
* `errors`

  A map, keyed by the field name. If an entry exists for a field, its
  value is the _first validation error_ associated with that field. 
  
* `fields`

  A reference to a field definition structure
  
  
So, we could do something like:

       neptune = Planet.new_record(
           name: "Neptune", 
           moon_count: 14)
           
       IO.inspect neptune.errors     #=> %{ mass: "must be present" }
       
       neptune = Planet.update(neptune, mass: 1.024e26
       
       IO.inspect neptune.errors     #=> %{ }
       IO.inspect neptune.valid?     #=> true
       
       
## Built-in Types

* All type accept the options:

  * `default:` _a type appropriate value_
  
  * `optional:` _defaults to `true` unless a default was provided
  
    In this world, an optional field is one that may have a nil value.
    Think of it as corresponding to the database `not null`
    constraint.


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

## Adding Your Own Types

A type is simply an Elixir module that:

1. is named `DD.Type.YourType`

2. uses the behaviour `DD.Type.Behaviour`

3. implements the handful of functions required by that behaviour.

If this module is loaded into your project, then the type becomes
available in `defrecord` as if it was a function named using the
lowercase form of the last part of the module name. So, in this
example, you could have

   defrecord do
     string(:name)
     your_type(:orbit_parameters)
   end
   
See the module doc for [Data.Type](,,,) for details.
   
       
       
