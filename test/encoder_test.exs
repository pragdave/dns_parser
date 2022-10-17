defmodule EncodingHelpers do
  use ExUnit.Case
  alias DnsPackets.PacketBuilder, as: PB
  alias PB.Section, as: PBS
  alias DnsPackets.Packets.{ Answer, Question }

  def into_context(encoded) do
    { encoded,
      12, 
      Map.new
    } 
  end

  def test_encoding(section, type, rdata, other_options \\ []) do
    options = 
      [ rdata: rdata, atype: type, name: "default-name", aclass: 1, flush_cache: false, ttl: 1234 ] 
      |> Keyword.merge(other_options)

    answer =  Answer.create(options)
    binary = section
             |> Answer.encode_into_section(answer)
             |> PBS.to_binary()

    { original, _ctx } = binary |> into_context() |> Answer.decode()
    assert original.name == options[:name]
    assert original.aclass == options[:aclass]
    assert original.atype == options[:atype]
    assert original.flush_cache == options[:flush_cache]
    assert original.ttl == options[:ttl]

    original.rdata
  end
end


defmodule EncoderTest do
  use ExUnit.Case
  alias DnsPackets.Packets.Question
  alias DnsPackets.PacketBuilder, as: PB
  alias DnsPackets.PacketBuilder.Section, as: PBS
  import EncodingHelpers

  setup do
    pb = PB.new()
    section = pb |> PB.new_section()
    %{ pb: pb, section: section }
  end

#  ╭──────────────────────────────────────────────────────────╮
#  │  This is the "can I read my own handwriting"             │
#  │  section of the testing...                               │
#  ╰──────────────────────────────────────────────────────────╯

  test "encode a question", t do
    binary = 
      t.section
      |> Question.encode_into_section("wombat", DnsPackets.RR.A.type) 
      |> PBS.to_binary()
    { original, _ctx } = binary |> into_context() |> Question.decode()
    assert original.name == "wombat"
    assert original.qtype == DnsPackets.RR.A.type()
    assert original.qclass == 1
  end

  test "encode a question with a complex name", t do
    binary = 
      t.section
      |> Question.encode_into_section("wombat.the.wombat", DnsPackets.RR.Ptr.type) 
      |> PBS.to_binary()

    { original, _ctx } = binary |> into_context() |> Question.decode()
    assert original.name == "wombat.the.wombat"
    assert original.qtype == DnsPackets.RR.Ptr.type()
    assert original.qclass == 1
  end


  test "Encode an A record", t do
    record = %DnsPackets.RR.A{ a: {1, 2, 3, 4}}
    rdata = test_encoding(t.section, DnsPackets.RR.A.type, record)
    assert rdata.a == {1, 2, 3, 4}
  end


  test "Encode a NS record", t do
    record = %DnsPackets.RR.Ns{ ns: "my_ns.com" }
    rdata = test_encoding(t.section, DnsPackets.RR.Ns.type, record)
    assert rdata.ns == "my_ns.com"
  end


  test "Encode a PTR record", t do
    record = %DnsPackets.RR.Ptr{ ptr: "look.over.there"}
    rdata = test_encoding(t.section, DnsPackets.RR.Ptr.type, record)
    assert rdata.ptr == "look.over.there"
  end

  test "Encode a Srv record", t do
    record = %DnsPackets.RR.Srv{ priority: 5, weight: 2, port: 1234, service: "_logger._udp" }
    rdata = test_encoding(t.section, DnsPackets.RR.Srv.type, record)
    assert rdata.priority == 5
    assert rdata.weight   == 2
    assert rdata.port     == 1234
    assert rdata.service  == "_logger._udp"
  end

  test "Encode a simple Txt record", t do
    record = %DnsPackets.RR.Txt{ txt: [ "hello world"] }
    rdata = test_encoding(t.section, DnsPackets.RR.Txt.type, record)
    assert rdata.txt  == [ "hello world" ]
  end

  test "Encode a multi-line Txt record", t do
    record = %DnsPackets.RR.Txt{ txt: [ "hello", "world", "!" ] }
    rdata = test_encoding(t.section, DnsPackets.RR.Txt.type, record)
    assert rdata.txt  == [ "hello", "world", "!" ]
  end

  # rr(:aaaa, 28, "ipv6 address",          aaaa:    RData.IPV6_Address)
end
