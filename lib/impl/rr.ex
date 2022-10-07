defmodule RData do
  defmodule IPV4_Address do
    def decode({ rest, offset, segments }) do
      << a::8, b::8, c::8, d::8, rest :: binary >> = rest
      { {a,b,c,d}, { rest, offset+4, segments } }
    end
    def encode({a,b,c,d}) do
      << a::8, b::8, c::8, d::9 >>
    end
  end

  defmodule String do
    def decode(context) do 
      Packet.decode_name(context)
    end
    def encode(_context, _name) do
      raise "not yet"      
    end
  end
end


defmodule RR do
  use RRHelpers

  rr(:a,  1, "IPV4 host address",    a: RData.IPV4_Address)
  rr(:ns, 2, "authoritative server", ns: RData.String)
  ###  rr(:cname, "cannonical name", cname: String.t)
  ###  rr(:soa, "start of authority zone", mname: String.t, rname: String.t, serial: integer, refresh: integer, retry: integer, expire: integer) 
  ###  rr(:null, "null resource record", data: binary)
  ###  rr(:wks, "well known service", a: IPV4_ADDRESS, protocol: integer, bitmap: binary)
  ###  rr(:ptr, "domain name pointer", iptr: String.t)
  ###  rr(:hinfo, "host information", cpu: String.t, os: String.t)
  ###  rr(:mx, "mail routing information", preference: integer, exchange: String.t)
  ###  rr(:txt, "text strings", strings: binary)
  ###  rr(:aaaa, "ipv6 address", aaaa: IPV6_ADDRESS)
  ###  rr(:srv, "services", priority: integer, weight: integer, port: integer, service: String.t)



  # rr(:minfo, "mailbox information", rmailbx: String.t, emailbx: String.t)
  # rr(:md, "mail destination", md: String.t )
  # rr(:mf, "mail forwarder", mf: String.t )
  # rr(:mb, "mailbox domain name", mb: String.t)
  # rr(:mg, "mail group member", mg: String.t)
  # rr(:mr, "mail rename name", mr: String.t)
  # @doc "naming authority pointer"
  # def naptr, do: 35
  # @doc "EDNS pseudo-rr RFC2671(7)"
  # def opt, do: 41
  # # SPF (RFC 4408)
  # @doc "server policy framework"
  # def spf, do: 99
  # #      non standard
  # @doc "user (finger) information"
  # def uinfo, do: 100
  # @doc "user ID"
  # def uid, do: 101
  # @doc "group ID"
  # def gid, do: 102
  # @doc "Unspecified format (binary data)"
  # def unspec, do: 103
  # # 	Query type values which do not appear in resource records
  # @doc "transfer zone of authority"
  # def axfr, do: 252
  # @doc "transfer mailbox records"
  # def mailb, do: 253
  # @doc "transfer mail agent records"
  # def maila, do: 254
  # @doc "wildcard match"
  # def any, do: 255
  # # URI (RFC 7553)
  # @doc "uniform resource identifier"
  # def uri, do: 256
  # # CAA (RFC 6844)
  # @doc "certification authority authorization"
    # def caa, do: 257
    #

  def decode(_context, type) do
    raise "Don't know how to decode type #{type}"
  end
end

