defmodule DnsPacketsTest do
  use ExUnit.Case

  alias DnsPackets.RR
  alias DnsPackets.Packets.{ Answer, Question}

  # qc = 0, ac = 7, add = 3
  # a1 = type 
  # @bad_length <<
  #   0x00, 0x00, 0x84, 0x00, 0x00, 0x00, 0x00, 0x07, 0x00, 0x00, 0x00, 0x03,
  #   0x16, 0x50, 0x72, 0x65, 0x63, 0x69, 0x6F, 0x75, 0x73, 0x20,
  #   0x69, 0x50, 0x68, 0x6F, 0x6E, 0x65, 0x20, 0x50, 0x72, 0x6F, 0x4D, 0x61, 0x78, 0x07, 0x5F, 0x72, 0x64, 0x6C, 0x69, 0x6E, 0x6B, 0x04, 0x5F, 0x74, 0x63, 0x70, 0x05, 0x6C, 0x6F, 0x63, 0x61, 0x6C, 0x00, 0x00, 0x10, 0x80, 0x01, 0x00, 0x00, 0x11, 0x94, 0x00, 0x34, 0x16, 0x72, 0x70, 0x42, 0x41, 0x3D, 0x35, 0x34, 0x3A, 0x30, 0x37, 0x3A, 0x36, 0x43, 0x3A, 0x32, 0x44, 0x3A, 0x37, 0x39, 0x3A, 0x45, 0x41, 0x0A, 0x72, 0x70, 0x56, 0x72, 0x3D, 0x33, 0x36, 0x30, 0x2E, 0x34, 0x11, 0x72, 0x70, 0x41, 0x44, 0x3D, 0x38, 0x31, 0x36, 0x35, 0x35, 0x34, 0x63, 0x32, 0x32, 0x35, 0x66, 0x62, 0x09, 0x5F, 0x73, 0x65, 0x72, 0x76, 0x69, 0x63, 0x65, 0x73, 0x07, 0x5F, 0x64, 0x6E, 0x73, 0x2D, 0x73, 0x64, 0x04, 0x5F, 0x75, 0x64, 0x70, 0xC0, 0x30, 0x00, 0x0C, 0x00, 0x01, 0x00, 0x00, 0x11, 0x94, 0x00, 0x02, 0xC0, 0x23, 0xC0, 0x23, 0x00, 0x0C, 0x00, 0x01, 0x00, 0x00, 0x11, 0x94, 0x00, 0x02, 0xC0, 0x0C, 0x16, 0x50, 0x72, 0x65, 0x63, 0x69, 0x6F, 0x75, 0x73, 0x20, 0x69, 0x50, 0x68, 0x6F, 0x6E, 0x65, 0x20, 0x50, 0x72, 0x6F, 0x4D, 0x61, 0x78, 0x0C, 0x5F, 0x64, 0x65, 0x76, 0x69, 0x63, 0x65, 0x2D, 0x69, 0x6E, 0x66, 0x6F, 0xC0, 0x2B, 0x00, 0x10, 0x00, 0x01, 0x00, 0x00, 0x11, 0x94, 0x00, 0x0C, 0x0B, 0x6D, 0x6F, 0x64, 0x65, 0x6C, 0x3D, 0x44, 0x36, 0x34, 0x41, 0x50, 0xC0, 0x0C, 0x00, 0x21, 0x80, 0x01, 0x00, 0x00, 0x00, 0x78, 0x00, 0x1F, 0x00, 0x00, 0x00, 0x00, 0xDF, 0x9C, 0x16, 0x50, 0x72, 0x65, 0x63, 0x69, 0x6F, 0x75, 0x73, 0x2D, 0x69, 0x50, 0x68, 0x6F, 0x6E, 0x65, 0x2D, 0x50, 0x72, 0x6F, 0x4D, 0x61, 0x78, 0xC0, 0x30, 0xC0, 0xF6, 0x00, 0x1C, 0x80, 0x01, 0x00, 0x00, 0x00, 0x78, 0x00, 0x10, 0xFE, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x1C, 0x60, 0xE3, 0x97, 0x9C, 0x2D, 0x9B, 0x8F, 0xC0, 0xF6, 0x00, 0x01, 0x80, 0x01, 0x00, 0x00, 0x00, 0x78, 0x00, 0x04, 0xC0, 0xA8, 0x56, 0x98, 0xC0, 0x0C, 0x00, 0x2F, 0x80, 0x01, 0x00, 0x00, 0x11, 0x94, 0x00, 0x09, 0xC0, 0x0C, 0x00, 0x05, 0x00, 0x00, 0x80, 0x00, 0x40, 0xC0, 0xF6, 0x00, 0x2F, 0x80, 0x01, 0x00, 0x00, 0x00, 0x78, 0x00, 0x08, 0xC0, 0xF6, 0x00, 0x04, 0x40, 0x00, 0x00, 0x08, 0x00, 0x00, 0x29, 0x05, 0xA0, 0x00, 0x00, 0x11, 0x94, 0x00, 0x12, 0x00, 0x04, 0x00, 0x0E, 0x00, 0xD6, 0xA6, 0xC3, 0x37, 0x2A, 0x0E, 0xF7, 0x62, 0x74, 0x75, 0x5F, 0x5F, 0x85
  # >>

  @nwu <<
  0xdb, 0x42, 0x81, 0x80, 0x00, 0x01, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x03, 0x77, 0x77, 0x77,
    0x0c, 0x6e, 0x6f, 0x72, 0x74, 0x68, 0x65, 0x61, 0x73, 0x74, 0x65, 0x72, 0x6e, 0x03, 0x65, 0x64, 
    0x75, 0x00, 0x00, 0x01, 0x00, 0x01, 0xc0, 0x0c, 0x00, 0x01, 0x00, 0x01, 0x00, 0x00, 0x02, 0x58, 
    0x00, 0x04, 0x9b, 0x21, 0x11, 0x44, 
    >>

  test "Basic A response" do
    r = DnsPackets.Packets.decode_packet(@nwu)

    h = r.header
    assert h.id     == 0xdb42
    assert h.qr     == :reply
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
      ttl_epoch: 1000,
      flush_cache: false,
      rdata: %RR.A{a: { 155, 33, 17, 68 }}
    }

    assert r.additional == []
    assert r.authorities == []
  end
end
