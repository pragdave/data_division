defmodule DD.MixProject do
  use Mix.Project
  
  @name    :dd
  @version "0.0.2"

  @deps [
    { :ex_doc,       ">= 0.0.0", only:    :dev  },
    { :gettext,      ">= 0.0.0"                 },
    { :phoenix_html, ">= 0.0.0", optional: true },
    { :todo,         ">= 1.0.0", optional: true },
    { :excoveralls,  ">= 0.0.0", only:    :test },
  ]

  @description """
  Create fieldsets (aka structs) with validation and
  Phoenix form_for compatibility, making it easier to 
  separate resource applications from your web frontend.
  """

  ############################################################
  
  def project do
    in_production = Mix.env == :prod
    [
      app:     @name,
      version: @version,
      elixir:  ">= 1.5.0",
      deps:    @deps,

      test_coverage: [tool: ExCoveralls],
      package:       package(),
      description:   @description,

      start_permanent:       in_production, 
      consolidate_protocols: in_production,
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

  defp package do
    [
      files: [
        "lib", "mix.exs", "README.md",
      ],
      maintainers: [
        "Dave Thomas <dave@pragdave.me>",
      ],
      licenses: [
        "Apache 2 (see the file LICENSE.md for details)"
      ],
      links: %{
        "GitHub" => "https://github.com/pragdave/data_division",
      }
    ]
  end
  
end
