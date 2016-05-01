require 'bindata'

require 'ledenet/packets/fields/checksum'
require 'ledenet/packets/empty_response'

module LEDENET::Packets
  class SetFunctionRequest < BinData::Record
    hide :checksum

    uint8 :packet_id, value: 0x61
    uint8 :function_id
    uint8 :speed
    uint8 :remote_or_local, value: 0x0F
    checksum :checksum, packet_data: ->() { snapshot }

    def response_reader
      LEDENET::Packets::EmptyResponse
    end
  end
end
