defmodule DnsPacketsTest do
  use ExUnit.Case

  @nwu <<
  0xdb, 0x42, 0x81, 0x80, 0x00, 0x01, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x03, 0x77, 0x77, 0x77,
    0x0c, 0x6e, 0x6f, 0x72, 0x74, 0x68, 0x65, 0x61, 0x73, 0x74, 0x65, 0x72, 0x6e, 0x03, 0x65, 0x64, 
    0x75, 0x00, 0x00, 0x01, 0x00, 0x01, 0xc0, 0x0c, 0x00, 0x01, 0x00, 0x01, 0x00, 0x00, 0x02, 0x58, 
    0x00, 0x04, 0x9b, 0x21, 0x11, 0x44, 
    >>

  test "Basic A response" do
    r = Packet.decode_packet(@nwu)

    h = r.header
    assert h.id     == 0xdb42
    assert h.qr     == true
    assert h.opcode == 0
    assert h.tc     == false
    assert h.rd     == true
    assert h.ra     == true
    assert h.rcode  == 0

    assert h.qd_count == 1
    assert h.an_count == 1
    assert h.ns_count == 0
    assert h.ar_count == 0

    assert length(r.questions) == 1
    q = hd r.questions
    assert q == %Question{name: "www.northeastern.edu", qclass: 1, qtype: 1}

    assert length(r.answers)== 1
    a = hd r.answers
    assert a == %Answer{
      name: "www.northeastern.edu", aclass: 1, atype: 1,
      ttl: 600,
      rdata: %RR.A{a: { 155, 33, 17, 68 }}
    }



    assert r.additional == []
    assert r.authorities == []


  end
end
