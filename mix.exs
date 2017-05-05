defmodule StubAlias.Mixfile do
  use Mix.Project

  @version "0.1.2"
  def project do
    [app: :stub_alias,
     version: @version,
     elixir: "~> 1.2",
     name: "stub_alias",
     source_url: "git@github.com:mgwidmann/stub_alias.git",
     homepage_url: "https://github.com/mgwidmann/stub_alias",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: "Environment specific aliases.",
     docs: [
       main: StubAlias,
       readme: "README.md"
     ],
     deps: deps(),
     package: package(),
     aliases: aliases()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:ex_doc, "~> 0.10", only: :dev},
      {:earmark, "~> 0.1", only: :dev}
    ]
  end

  defp package do
    [
      maintainers: ["Matt Widmann"],
      licenses: ["MIT"],
      links: %{github: "https://github.com/mgwidmann/stub_alias"}
    ]
  end
  defp aliases do
    [publish: ["hex.publish", "hex.publish docs", "tag"],
     tag: &tag_release/1]
  end

  defp tag_release(_) do
    Mix.shell.info "Tagging release as #{@version}"
    System.cmd("git", ["tag", "-a", "v#{@version}", "-m", "v#{@version}"])
    System.cmd("git", ["push", "--tags"])
  end
end
