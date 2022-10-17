defmodule PacketBuilderQueryTest do
  use ExUnit.Case
  alias DnsPackets.PacketBuilder, as: PB 

  setup do
    %{ pb: PB.new }
  end

  test "simple query test", t  do
    result =
      t.pb
      |> PB.add_question("wombat", DnsPackets.RR.A.type) 
      |> PB.to_packet(id: 1234, qr: :query)
    
    q = 
      result
      |> List.flatten  # it'a an IOLIST
      |> Enum.join
      |> DnsPackets.Packets.decode_packet

    assert q.header.id == 1234
    assert q.header.qr == :query
    assert q.header.qd_count == 1
    assert length(q.questions) == 1

    question = hd q.questions
    assert question.name == "wombat"
    assert question.qtype == DnsPackets.RR.A.type
  end


end
