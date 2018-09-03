defmodule HorseStapleBattery.MixProject do
  use Mix.Project

  def project do
    [
      app: :horsestaplebattery,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      description: description()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [{:ex_doc, ">= 0.0.0", only: :dev}]
  end

  defp package() do
    [
      # These are the default files included in the package
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      licenses: ["Apache 2.0"],
      maintainers: ["Christophe De Troyer"],
      links: %{"GitHub" => "https://github.com/m1dnight/horsestaplebattery"}
    ]
  end

  defp description do
    """
    A simple Horse Staple Battery generator.
    """
  end
end
