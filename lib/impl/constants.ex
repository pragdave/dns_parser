defmodule DNSPackets.Packets.Opcode do
  @compile {:inline, query: 0, iquery: 0, status: 0, updatea: 0, updated: 0}
  @compile {:inline, updateda: 0, updatem: 0, updatema: 0, zoneinit: 0, zoneref: 0}

  @type t :: 0 | 1 | 2 | 9 | 0x0a | 0x0b | 0x0c | 0x0d | 0x0e | 0x0f
  @doc "standard query"
  def query, do: 0x0
  @doc "inverse query "
  def iquery, do: 0x1
  @doc "nameserver status query "
  def status, do: 0x2
  @doc "add resource record"
  def updatea, do: 0x9
  @doc "delete a specific resource record"
  def updated, do: 0xA
  @doc "delete all nemed resource record"
  def updateda, do: 0xB
  @doc "modify a specific resource record"
  def updatem, do: 0xC
  @doc "modify all named resource record"
  def updatema, do: 0xD
  @doc "initial zone transfer "
  def zoneinit, do: 0xE
  @doc "incremental zone referesh"
  def zoneref, do: 0xF
end

#
# Currently defined response codes
#
defmodule DNSPackets.Packets.RC do
  @compile {:inline, noerror: 0, formerr: 0, servfail: 0, nxdomain: 0, notimp: 0}
  @compile {:inline, refused: 0, nochange: 0, badvers: 0}

  @type t :: 0 | 1 | 2 | 3 | 5 | 5 | 0x0f | 16

  @doc "no error"
  def noerror, do: 0
  @doc "format error"
  def formerr, do: 1
  @doc "server failure"
  def servfail, do: 2
  @doc "non existent domain"
  def nxdomain, do: 3
  @doc "not implemented"
  def notimp, do: 4
  @doc "query refused"
  def refused, do: 5
  # 	non standard 
  # update failed to change db
  def nochange, do: 0xF
  def badvers, do: 16
end

##
## Type values for resources and queries
##
#defmodule DnsPackets.Packets.T do

#  @type t :: integer()
 
#  @compile {:inline, a: 0, ns: 0, md: 0, mf: 0, cname: 0}
#  @compile {:inline, soa: 0, mb: 0, mg: 0, mr: 0, null: 0}
#  @compile {:inline, wks: 0, ptr: 0, hinfo: 0, minfo: 0, mx: 0}
#  @compile {:inline, txt: 0, aaaa: 0, srv: 0, naptr: 0, opt: 0}
#  @compile {:inline, spf: 0, uinfo: 0, uid: 0, gid: 0, unspec: 0}
#  @compile {:inline, axfr: 0, mailb: 0, maila: 0, any: 0, uri: 0, caa: 0}

#  @doc "host address"
#  def a, do: 1
#  @doc "authoritative server"
#  def ns, do: 2
#  @doc "mail destination"
#  def md, do: 3
#  @doc "mail forwarder"
#  def mf, do: 4
#  @doc "connonical name"
#  def cname, do: 5
#  @doc "start of authority zone"
#  def soa, do: 6
#  @doc "mailbox domain name"
#  def mb, do: 7
#  @doc "mail group member"
#  def mg, do: 8
#  @doc "mail rename name"
#  def mr, do: 9
#  @doc "null resource record"
#  def null, do: 10
#  @doc "well known service"
#  def wks, do: 11
#  @doc "domain name pointer"
#  def ptr, do: 12
#  @doc "host information"
#  def hinfo, do: 13
#  @doc "mailbox information"
#  def minfo, do: 14
#  @doc "mail routing information"
#  def mx, do: 15
#  @doc "text strings"
#  def txt, do: 16
#  @doc "ipv6 address"
#  def aaaa, do: 28
#  # SRV (RFC 2052)
#  @doc "services"
#  def srv, do: 33
#  # NAPTR (RFC 2915)
#  @doc "naming authority pointer"
#  def naptr, do: 35
#  @doc "EDNS pseudo-rr RFC2671(7)"
#  def opt, do: 41
#  # SPF (RFC 4408)
#  @doc "server policy framework"
#  def spf, do: 99
#  #      non standard
#  @doc "user (finger) information"
#  def uinfo, do: 100
#  @doc "user ID"
#  def uid, do: 101
#  @doc "group ID"
#  def gid, do: 102
#  @doc "Unspecified format (binary data)"
#  def unspec, do: 103
#  # 	Query type values which do not appear in resource records
#  @doc "transfer zone of authority"
#  def axfr, do: 252
#  @doc "transfer mailbox records"
#  def mailb, do: 253
#  @doc "transfer mail agent records"
#  def maila, do: 254
#  @doc "wildcard match"
#  def any, do: 255
#  # URI (RFC 7553)
#  @doc "uniform resource identifier"
#  def uri, do: 256
#  # CAA (RFC 6844)
#  @doc "certification authority authorization"
#  def caa, do: 257
#end

##
## Symbolic Type values for resources and queries
##
#defmodule DnsPackets.Packets.S do
#  @compile {:inline, s_a: 0, s_ns: 0, s_md: 0, s_mf: 0, s_cname: 0}
#  @compile {:inline, s_soa: 0, s_mb: 0, s_mg: 0, s_mr: 0, s_null: 0}
#  @compile {:inline, s_wks: 0, s_ptr: 0, s_hinfo: 0, s_minfo: 0, s_mx: 0}
#  @compile {:inline, s_txt: 0, s_aaaa: 0, s_srv: 0, s_naptr: 0, s_opt: 0}
#  @compile {:inline, s_spf: 0, s_uinfo: 0, s_uid: 0, s_gid: 0, s_unspec: 0}
#  @compile {:inline, s_axfr: 0, s_mailb: 0, s_maila: 0, s_any: 0}
#  @compile {:inline, s_uri: 0, s_caa: 0}

#  @doc "host address"
#  def s_a, do: :a
#  @doc "authoritative server"
#  def s_ns, do: :ns
#  @doc "mail destination"
#  def s_md, do: :md
#  @doc "mail forwarder"
#  def s_mf, do: :mf
#  @doc "connonical name"
#  def s_cname, do: :cname
#  @doc "start of authority zone"
#  def s_soa, do: :soa
#  @doc "mailbox domain name"
#  def s_mb, do: :mb
#  @doc "mail group member"
#  def s_mg, do: :mg
#  @doc "mail rename name"
#  def s_mr, do: :mr
#  @doc "null resource record"
#  def s_null, do: :null
#  @doc "well known service"
#  def s_wks, do: :wks
#  @doc "domain name pointer"
#  def s_ptr, do: :ptr
#  @doc "host information"
#  def s_hinfo, do: :hinfo
#  @doc "mailbox information"
#  def s_minfo, do: :minfo
#  @doc "mail routing information"
#  def s_mx, do: :mx
#  @doc "text strings"
#  def s_txt, do: :txt
#  @doc "ipv6 address"
#  def s_aaaa, do: :aaaa
#  # SRV (RFC 2052)
#  @doc "services"
#  def s_srv, do: :srv
#  # NAPTR (RFC 2915)
#  @doc "naming authority pointer"
#  def s_naptr, do: :naptr
#  @doc "EDNS pseudo-rr RFC2671(7)"
#  def s_opt, do: :opt
#  # SPF (RFC 4408)
#  @doc "server policy framework"
#  def s_spf, do: :spf
#  #      non standard
#  @doc "user (finger) information"
#  def s_uinfo, do: :uinfo
#  @doc "user ID"
#  def s_uid, do: :uid
#  @doc "group ID"
#  def s_gid, do: :gid
#  @doc "Unspecified format (binary data)"
#  def s_unspec, do: :unspec
#  # 	Query type values which do not appear in resource records
#  @doc "transfer zone of authority"
#  def s_axfr, do: :axfr
#  @doc "transfer mailbox records"
#  def s_mailb, do: :mailb
#  @doc "transfer mail agent records"
#  def s_maila, do: :maila
#  @doc "wildcard match"
#  def s_any, do: :any
#  # URI (RFC 7553)
#  @doc "uniform resource identifier"
#  def s_uri, do: :uri
#  # CAA (RFC 6844)
#  @doc "certification authority authorization"
#  def s_caa, do: :caa
#end

#
# Values for class field
#
defmodule DnsPackets.Packets.C do

  @type t :: 1 | 3 | 4 | 255

  @compile {:inline, c_in: 0, c_chaos: 0, c_hs: 0, c_any: 0}

  @doc "the arpa internet"
  def c_in, do: 1
  @doc "for chaos net at MIT"
  def c_chaos, do: 3
  @doc "for Hesiod name server at MIT"
  def c_hs, do: 4
  #  Query class values which do not appear in resource records
  @doc "wildcard match "
  def c_any, do: 255
end


