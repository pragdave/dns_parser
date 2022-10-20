defmodule DnsPackets.Packets.Answer do 

  alias DnsPackets.PacketBuilder.Section, as: PBS
  alias DnsPackets.{ Packets, RR }
  import Bitwise
  require Logger

  defstruct [ :name, :atype, :aclass, :flush_cache, :ttl, :ttl_epoch, :rdata ]

  @type t :: %__MODULE__{
    name: String.t, atype: Packet.T.t, aclass: Packet.C.t,
    flush_cache: boolean, ttl: integer(), ttl_epoch: integer(), rdata: binary, 
  }

  def create(options) do
    struct(__MODULE__, options)
  end

  def decode(context) do
    { name, {rest, offset, segments} } = Packets.Names.decode_name(context)

    << 
      atype :: 16, 
      aclass :: 16, 
      ttl :: 32,
      rdlength :: 16, 
      rest :: binary 
    >> = rest

    flush_cache = (aclass &&& 0x8000) != 0
    aclass = aclass &&& 0x7fff 

    try do
      { rdata, context, _length_left } = decode_and_verify_length(rest, offset+10, segments, atype, rdlength)
      # { _, offset, _} = context
      # raw_len = offset - start_offset
      # << raw :: binary-size(raw_len), _ :: binary >> = start_rest
      result = %__MODULE__{
        name: name, 
        atype: atype,
        aclass: aclass,
        flush_cache: flush_cache,
        ttl: ttl,
        ttl_epoch: DnsPackets.MyTime.now,
        rdata: rdata,
        # raw: raw,
      }

      { result, context}

    rescue e in MatchError -> 
        Logger.error("Failed to decode #{atype}")
        reraise e, __STACKTRACE__
    end
  end

  @spec encode_into_section(PBS.t, t) :: PBS.t
  def encode_into_section(section, answer) do
    section = 
      section
      |> PBS.add_name(answer.name)
      |> PBS.add_binary(<< 
        answer.atype :: 16, 
        answer.aclass :: 16,
        answer.ttl :: 32,
        >>)
      |> PBS.bump_offset(2)  # we'll add rdlength later

    rdata = section 
            |> PBS.remove_content 
            |> RR.encode_into_section(answer)
            |> PBS.to_binary()

    # now add the rdlength before the rdata
    section
    |> PBS.bump_offset(-2)
    |> PBS.add_binary(<< byte_size(rdata) :: 16 >>)
    |> PBS.add_binary(rdata)
  end

  def matches_query(answer, name, type) do
     answer.atype == type && answer.name == name 
  end

  def decode_and_verify_length(rest, offset, segments, atype, rdlength) do 
    result = { rdata, _context, length_left } = RR.decode({ rest, offset+10, segments }, atype, rdlength)
    if length_left != 0 do
      Logger.error("RR.decode failed to read correct length.")
      Logger.error("#{length_left} bytes remaining")
      Logger.error(inspect rest)
      Logger.error(inspect rdata)
      raise "RR.decode failed to read correct length."
    else
      result
    end
  end
end

