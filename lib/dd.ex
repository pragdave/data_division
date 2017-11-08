defmodule DD do

  defmacro __using__(args) do
    quote do
      use(DD.Impl, args)
    end
  end
end
