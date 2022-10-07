# DnsPackets: DNS Packet Encode and Decode

I needed a simple, pure-Elixir library to encode and decode
DNS packets.

Right now, it's still in development, and only a handful or RR types
have been implemented (I wanted to move on to the code that used this
library). However, new RRs can be added with a wingle line of code (see
`lib/impl/rr.ex`)

## Installation

```elixir
    {:dns_packets, "~> 0.1.0"}
```

## License

Copyright (c) 2022 Dave Thomas <@pragdave>

Made available under the MIT license.
