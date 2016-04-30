require 'bindata'

require 'ledenet/packets/fields/checksum'

module LEDENET::Packets
  class StatusResponse < BinData::Record
    hide :checksum, :unused_payload

    uint8 :packet_id, value: 0x81
    uint8 :device_name
    uint8 :power_status

    # I'm not sure these are the correct field labels.  Basing it off of some
    # documentation that looks like it's for a slightly different protocol.
    uint8 :mode
    uint8 :run_status
    uint8 :speed

    uint8 :red
    uint8 :green
    uint8 :blue
    uint8 :warm_white

    uint16be :unused_payload, value: 0x0000
    uint8 :checksum

    def on?
      (power_status & 0x01) == 0x01
    end
  end
end
