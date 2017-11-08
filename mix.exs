defmodule DDD.MixProject do
  use Mix.Project
  
  def project do
    [
      app:     :data,
      version: "0.1.0",
      elixir:  "~> 1.6-dev",
      deps:    deps(),
    
      start_permanent:       Mix.env == :prod, 
      consolidate_protocols: Mix.env != :test,   
    ]
  end

  def application do
    [
      extra_applications: [
        :logger
      ]
    ]
  end

  defp deps do
    [
      { :phoenix_html, ">= 0.0.0", optional: true }
    ]
  end
end
