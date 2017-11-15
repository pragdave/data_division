defmodule DDD.MixProject do
  use Mix.Project
  
  def project do
    [
      app:     :dd,
      version: "0.1.0",
      elixir:  "~> 1.6-dev",
      deps:    deps(),

      test_coverage: [tool: ExCoveralls],
      
      start_permanent:       Mix.env == :prod, 
      consolidate_protocols: !(Mix.env in [ :dev, :test ]),   
    ]
  end

  def application do
    [
      extra_applications: [
        :logger,
        :gettext
      ]
    ]
  end

  # in deps, add the depedency for only test environment
  defp deps do
    [
      { :gettext,      ">= 0.0.0" },
      { :phoenix_html, ">= 0.0.0", optional: true },
      { :todo,         ">= 1.0.0" },
      { :excoveralls,  ">= 0.0.0", only: :test },
    ]
  end
end
