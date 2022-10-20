defmodule DnsPackets do

  @moduledoc File.read!("README.md")

  @doc """
  Parse the binary data of a DNS message into a header and (posentially empty)
  lists of questions, answers, authorities,a nd additional information RRs.

  
  """

  @spec decode(binary) :: DnsPackets.Packets.t 
  defdelegate decode(dns_data), to: DnsPackets.Packets, as: :decode_packet

end
