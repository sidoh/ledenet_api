require 'bindata'

require 'ledenet/packets/fields/checksum'
require 'ledenet/packets/empty_response'

module LEDENET::Packets
  class UpdateColorRequest < BinData::Record
    hide :checksum

    uint8 :packet_id, value: 0x31

    uint8 :red
    uint8 :green
    uint8 :blue
    uint8 :warm_white

    uint8 :unused_payload, value: 0

    # Not clear to me what difference this makes. Remote = 0xF0, Local = 0x0F
    uint8 :remote_or_local, value: 0x0F

    checksum :checksum, packet_data: ->() { snapshot }

    def response_reader
      LEDENET::Packets::EmptyResponse
    end
  end
end
