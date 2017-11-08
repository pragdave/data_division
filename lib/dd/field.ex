defmodule DD.Field do

  defstruct(
    name:        "",
    type:        :nil,
    constraints: %{}
  )

  @type t :: %DD.Field{}
  
end
