defmodule DnsPackets.RData do
  alias DnsPackets.PacketBuilder.Section, as: PBS
  alias DnsPackets.Packets.Names

  defmodule DecodeEncode do
    @callback decode(Packets.parse_context, integer) :: { term, Packets.parse_context, integer }
  end
  @moduledoc """
  Encoders and decoders for the various field types that occur in RData. The `Raw`
  module handles rdata blocks that haven't yet been explicitly decoded in 
  `rr.ex`, and simply represents the rdata as a binary
  """

  defmodule BMap do
    @behaviour DecodeEncode

    def decode({rest, offset, segments}, length_left) do 
      << bmap :: binary-size(length_left), rest :: binary >> = rest
      { bmap, { rest, offset+length_left, segments}, 0}
    end

    def encode_into_section(section,  val) do
      section |> PBS.add_binary(val)
    end

    def format(val) do
      inspect val
    end
  end

  defmodule Int16 do
    @behaviour DecodeEncode

    def decode({ rest, offset, segments }, length_left) do
      << val :: 16, rest :: binary >> = rest
      { val, { rest, offset+2, segments }, length_left-2 }
    end

    def encode_into_section(section, val) do
      section |> PBS.add_binary(<< val::16 >>)
    end

    def format(val) do
      to_string(val)
    end
  end


  defmodule IPV4_Address do
    @behaviour DecodeEncode

    def decode({ rest, offset, segments }, length_left) do
      << a::8, b::8, c::8, d::8, rest :: binary >> = rest
      { {a,b,c,d}, { rest, offset+4, segments }, length_left-4 }
    end

    def encode_into_section(section, {a,b,c,d})  do
      section |> PBS.add_binary(<< a::8, b::8, c::8, d::8 >>)
    end

    def format({a,b,c,d}) do
      "#{a}.#{b}.#{c}.#{d}"
    end
  end

  defmodule IPV6_Address do
    @behaviour DecodeEncode

    def decode({ rest, offset, segments }, length_left) do
      << addr :: binary-size(16), rest :: binary >> = rest
      { addr, { rest, offset+16, segments }, length_left-16 }
    end

    def encode_into_section(section, addr) do
      section |> PBS.add_binary(<< addr :: 8*16 >>)
    end

    def format(val) do
      inspect val
      # for << w::16 <- val >>, do: Integer.to_string(w, 16)
      # |> Enum.join(":")
    end
  end

  defmodule KeyValuePairs do
    @behaviour DecodeEncode
    def decode(context, length_left) do
      decode_kv_list(context, length_left, []) 
    end

    def encode_into_section(_section, _list) do
      raise "Not implemented"
    end

    def format(val) do
      inspect(val)
    end

    defp decode_kv_list(_context, left, _) when left < 0 do
      raise "Overshot decoding KeyValuePairs"
    end

    defp decode_kv_list(context, 0, result) do
      { Enum.reverse(result), context, 0 }
    end

    defp decode_kv_list({rest, offset, segments}, length_left, result) do
      << option_code::16, len::16, data::binary-size(len), rest :: binary >> = rest
      decode_kv_list(
        { rest, offset + 4 + len, segments },
        length_left - len - 4,
        [ { option_code, data} | result ]
      )
    end
  end

  defmodule Name do
    @behaviour DecodeEncode

    def decode({_, offset1, _} = context, length_left) do 
      { name, {rest, offset2, segments} } = Names.decode_name(context)
      { name, {rest, offset2, segments }, length_left - (offset2 - offset1) }
    end

    def encode_into_section(section, name) do
      section |> PBS.add_name(name)
    end

    def format(val) do 
      val
    end
  end

  defmodule Raw do
    @behaviour DecodeEncode

    def decode({rest, offset, segments}, length_left) do
      << bin :: binary-size(length_left), rest :: binary >> = rest
      { bin, { rest, offset + length_left, segments}, 0 }
    end

    def encode_into_section(section, binary) do
      section |> PBS.add_binary(binary)
    end

    def format(val) do 
      inspect val
    end
  end

  defmodule String do
    @behaviour DecodeEncode

    def decode({rest, offset, segments}, length_left) do
      << len :: 8, str :: binary-size(len), rest :: binary >> = rest
      { str, { rest, offset + len + 1, segments}, length_left - len - 1}
    end

    def encode_into_section(section, string) do
      section |> PBS.add_single_string(string)
    end

    def format(val) do 
      val
    end
  end

  defmodule Strings do
    @behaviour DecodeEncode

    def decode(context, length_left) do
      { context, 0, strings } = decode_list_of_strings(context, length_left, [])
      { strings, context, 0 }
    end
    def encode_into_section(section,  strings) do
      strings
      |> Enum.reduce(section, fn str, section -> section |> PBS.add_single_string(str) end)
    end

    def format(val) do 
      val |> Enum.map(&inspect/1) |> Enum.join("\n")
    end

    @spec decode_list_of_strings(Packets.parse_context, number, [String.t]) :: { Packets.parse_context, number, [ String.t]}
    def decode_list_of_strings(_context, length_left, _result) when length_left < 0 do
      raise "Overshot list of strings"
    end

    def decode_list_of_strings(context, 0, result) do
      { context, 0, Enum.reverse(result) }
    end

    def decode_list_of_strings({rest, offset, segments}, length_left, result) do
      << len :: 8, str :: binary-size(len), rest :: binary >> = rest
      len = len + 1
      decode_list_of_strings(
        { rest, offset + len, segments}, 
        length_left - len, 
        [ str | result ]
      )
    end
  end
end


