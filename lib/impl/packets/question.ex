defmodule DnsPackets.Packets.Question do
  alias DnsPackets.PacketBuilder.Section, as: PBS

  defstruct [ :name, :qtype, :qclass  ]
  @type t :: %__MODULE__{name: String.t, qtype: Packet.T.t, qclass: Packet.C.t }

  def decode(context) do
    { name, {rest, offset, segments} } = DnsPackets.Packets.Names.decode_name(context)
    << qtype :: 16, qclass :: 16, rest :: binary >> = rest
    offset = offset + 4
    result = %__MODULE__{ name: name, qtype: qtype, qclass: qclass }
    { result, { rest, offset, segments }}
  end

  def encode_into_section(section, name, type) do
      section
      |> PBS.add_name(name)
      |> PBS.add_binary(<< type :: 16, 1 :: 16 >>)
  end
end
