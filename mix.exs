defmodule DnsPackets.MixProject do
  use Mix.Project

  def project do
    [
      app:     :dns_packets,
      version: "0.1.0",
      elixir:  "~> 1.13",
      deps:    deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      { :typed_struct, "> 0.0.0" },
      { :dialyxir, "~> 1.0", only: [:dev], runtime: false },   
    ]
  end
end
