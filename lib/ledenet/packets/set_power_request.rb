require 'bindata'

require 'ledenet/packets/fields/checksum'
require 'ledenet/packets/empty_response'

module LEDENET::Packets
  class SetPowerRequest < BinData::Record
    mandatory_parameter :on?
    hide :checksum

    uint8 :packet_id, value: 0x71
    uint8 :power_status, value: ->() { on? ? 0x23 : 0x24 }
    uint8 :remote_or_local, value: 0x0F

    checksum :checksum, packet_data: ->() { snapshot }

    def response_reader
      LEDENET::Packets::EmptyResponse
    end

    def self.on_request
      SetPowerRequest.new(on?: true)
    end

    def self.off_request
      SetPowerRequest.new(on?: false)
    end
  end
end
