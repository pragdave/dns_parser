defmodule DnsPackets.RR do
  use DnsPackets.RRHelpers

  alias DnsPackets.RData

  rr(:a,     1,  "IPV4 host address",    a:       RData.IPV4_Address)
  rr(:ns,    2,  "authoritative server", ns:      RData.Name)
  rr(:ptr,  12, "domain name pointer",   ptr:     RData.Name)
  rr(:txt,  16, "text strings",          txt:     RData.Strings)
  rr(:aaaa, 28, "ipv6 address",          aaaa:    RData.IPV6_Address)
  rr(:nsec, 47, "Next secure record",    nxtname: RData.Name, bmap: RData.BMap) # spec says it should be a string, but...
  rr(:opt,  41, "Option",                opt:     RData.KeyValuePairs)

  rr(:srv, 33, "services", 
    priority: RData.Int16, weight: RData.Int16, port: RData.Int16, service: RData.Name)

#  ╭─────────────────────────────────────────────────────────╮
#  │ The following will successfully encode and decode,      │
#  │ and so can be sent back as Known Answers in             │
#  │ question requests. If you need to parse them to         │
#  │ access the data when fetching resources, simply         │
#  │ add the fields and field types in place of the          │
#  │ `rdata: RData.raw` field                                │
#  ╰─────────────────────────────────────────────────────────╯

  rr(:cname,  5,   "cannonical name", rdata: RData.Raw)
  rr(:hinfo,  13,  "host information", rdata: RData.Raw)
  rr(:mb,     7,   "mailbox domain name", rdata: RData.Raw)
  rr(:md,     3,   "mail destination", rdata: RData.Raw)
  rr(:mf,     4,   "mail forwarder", rdata: RData.Raw)
  rr(:mg,     8,   "mail group member", rdata: RData.Raw)
  rr(:minfo,  14,  "mailbox information", rdata: RData.Raw)
  rr(:mr,     9,   "mail rename name", rdata: RData.Raw)
  rr(:mx,     15,  "mail routing information", rdata: RData.Raw)
  rr(:naptr,  35,  "naming authority pointer", rdata: RData.Raw)
  rr(:null,   10,  "null resource record", rdata: RData.Raw)
  rr(:soa,    6,   "start of authority zone", rdata: RData.Raw)
  rr(:wks,    11,  "well known service", rdata: RData.Raw)
   
  # # SPF (RFC 4408)
  rr(:spf,    99,  "server policy framework", rdata: RData.Raw)

  # #      non standard
  rr(:gid,    102, "group ID", rdata: RData.Raw)
  rr(:uid,    101, "user ID", rdata: RData.Raw)
  rr(:uinfo,  100, "user (finger) information", rdata: RData.Raw)
  rr(:unspec, 103, "Unspecified format (binary data)", rdata: RData.Raw)
  # # 	Query type values which do not appear in resource records
  rr(:any,    255, "wildcard match", rdata: RData.Raw)
  rr(:axfr,   252, "transfer zone of authority", rdata: RData.Raw)
  rr(:maila,  254, "transfer mail agent records", rdata: RData.Raw)
  rr(:mailb,  253, "transfer mailbox records", rdata: RData.Raw)

  # # URI (RFC 7553)
  rr(:uri,    256, "uniform resource identifier", rdata: RData.Raw)

  # # CAA (RFC 6844)
  rr(:caa,    257, "certification authority authorization", rdata: RData.Raw)
    

  # def decode({ rest, offset, original }, type, length) do
  #   raise "\n\nDon't know how to decode type #{type} (length #{length})\n\n"
  # end

  def format(answer = %{ atype: atype, rdata: rdata }) do
    rdata = case atype do 
      1 -> [ "a",  RData.IPV4_Address.format(rdata.a) ]
      2 -> [ "ns",  RData.Name.format(rdata.ns) ]
      12 -> [ "ptr",  RData.Name.format(rdata.ptr) ]
      16 -> [ "txt",  RData.Strings.format(rdata.txt) ]
      28 -> [ "aaaa",  RData.IPV6_Address.format(rdata.aaaa) ]
      47 -> [ "nsec",  
          RData.Name.format(rdata.nxtname),
          RData.BMap.format(rdata.bmap),
      ]
      33 -> [ "srv", 
          RData.Int16.format(rdata.priority), 
          RData.Int16.format(rdata.weight), 
          RData.Int16.format(rdata.port), 
          RData.Name.format(rdata.service)
      ]
      _ ->
        [ "unsupported type #{answer.type}"]
    end

    [
      answer.name |> String.pad_trailing(20),
      answer.ttl  |> Integer.to_string |> String.pad_leading(5),
      answer.aclass |> Integer.to_string,
      (if answer.flush_cache, do: "*F*", else: "   ")
      | rdata
    ] |> Enum.join(" ")
  end
end

