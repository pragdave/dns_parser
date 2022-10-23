defmodule DnsPackets.Packets.Answer do 

  alias DnsPackets.PacketBuilder.Section, as: PBS
  alias DnsPackets.{ Packets, RR }
  import Bitwise
  require Logger

  use TypedStruct

  typedstruct do
    field :name,        String.t     # the name of this resource
    field :atype,       RR.rr_type_numbers   # the (integer) packet type (A = 1, etc)
    field :aclass,      Packets.C.t   # the protocol class (always 1)
    field :flush_cache, boolean      # this data replaces existing data
    field :ttl,         integer()    # the time-to-live (see below)
    field :ttl_epoch,   integer()    # ...
    field :rdata,       RR.rr_type_names  # the resource type specific data
  end


  def create(options) do
    struct(__MODULE__, options)
  end

  def decode(context) do
    { name, {rest, offset, original} } = Packets.Names.decode_name(context)

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
      { rdata, context, _length_left } = decode_and_verify_length(rest, offset+10, original, atype, rdlength)
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

  def decode_and_verify_length(rest, offset, original, atype, rdlength) do 
    result = { rdata, _context, length_left } = RR.decode({ rest, offset+10, original }, atype, rdlength)
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

