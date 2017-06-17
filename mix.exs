defmodule PhoenixVueHelpers.Mixfile do
  use Mix.Project

  def project do
    [app: :phoenix_vue_helpers,
     version: "0.1.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     package: [
         contributors: ["Guillaume Ballet"],
         maintainers: ["Guillaume Ballet"],
         licences: ["The Unlicense"],
         links: %{github: "TODO"},
         files: ~w(lib priv mix.exs UNLICENSE)
     ],
     description: """
     Helpers for using Vuejs in Phoenix applications.
     """,
     source_url: "https://github.com/gballet/phoenix_vue_helpers"
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [applications: [:phoenix]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
        {:phoenix, "~> 1.2.4"}
    ]
  end
end
