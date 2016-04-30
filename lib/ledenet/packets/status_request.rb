require 'bindata'

require 'ledenet/packets/fields/checksum'
require 'ledenet/packets/status_response'

module LEDENET::Packets
  class StatusRequest < BinData::Record
    hide :checksum

    uint8 :packet_id, value: 0x81
    uint8 :payload1, value: 0x8A
    uint8 :payload2, value: 0x8B

    checksum :checksum, packet_data: ->() { snapshot }

    def response_reader
      LEDENET::Packets::StatusResponse
    end
  end
end
