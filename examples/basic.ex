defmodule Examples.Basic do

  use Data

  defrecord do
    string(:name, default: "dave", max: 6+1)
    string(:state, matches: ~r/x/)
  end

end

IO.inspect Examples.Basic.__fields
IO.inspect Examples.Basic.__defaults

# data = Examples.Basic.new_record( name: "wombat", state: "sleeping" ) #
# IO.inspect data
# 
# data = Examples.Basic.new_record() # 
# 
# IO.inspect data
# 
# data = Examples.Basic.new_record( name: "kangaroo", state: "sleeping" ) #
# IO.inspect data
# 
# data = Examples.Basic.new_record( name: 99, state: "sleeping" ) #
# IO.inspect data
