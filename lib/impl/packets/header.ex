defmodule DnsPackets.Packets.Header do

  defstruct [
   :id, :qr, :opcode, :aa, :tc, :rd, :ra, :pr, :rcode,
    :qd_count, :an_count, :ns_count, :ar_count,
    :raw,
  ]

  @type t :: %__MODULE__{ 
    id: integer(),
    qr: :query | :reply,
    opcode: Packer.Opcode.t,
    aa: boolean,
    tc: boolean,
    rd: boolean,
    ra: boolean,
    pr: boolean,
    rcode: Packet.RC.t,
    qd_count: integer(),
    an_count: integer(),
    ns_count: integer(),
    ar_count: integer(),
    raw: binary,
  }

  def from_binary(<<
    id :: 16, qr :: 1, opcode :: 4, aa :: 1, tc :: 1, rd :: 1, 
    ra :: 1, pr :: 1, _unused :: 2, rcode :: 4, 
    qd_count :: 16, an_count :: 16, ns_count :: 16, ar_count :: 16,
    rest :: binary
    >> = original) 
  do
    << raw::binary-size(13), _ :: binary >> = original
    {
      %__MODULE__{
      id: id,
      qr: (if qr == 0, do: :query, else: :reply),
      opcode: opcode,
      aa: aa != 0,
      tc: tc != 0,
      rd: rd != 0,
      ra: ra != 0,
      pr: pr != 0,
      rcode: rcode,
      qd_count: qd_count,
      an_count: an_count,
      ns_count: ns_count,
      ar_count: ar_count,
      raw: raw},
      rest
    }
  end

  def to_binary(header) do
    <<
    header.id :: 16, 
      (if header.qr == :query, do: 0, else: 1) :: 1, 
      header.opcode :: 4, header.aa :: 1, header.tc :: 1, header.rd :: 1, 
      header.ra :: 1, header.pr :: 1, 0 :: 2, header.rcode :: 4, 
      header.qd_count :: 16, header.an_count :: 16, header.ns_count :: 16, header.ar_count :: 16
    >>
  end

  @defaults [
    id: 1234,
      qr: :reply,
      opcode: 0,
      aa: 0,
      tc: 0,
      rd: 0,
      ra: 0,
      pr: 0,
      rcode: 0,
      qd_count: 0,
      an_count: 0,
      ns_count: 0,
      ar_count: 0
  ]

  def new(options) do
    struct(__MODULE__, Keyword.merge(@defaults, options))
  end
end
