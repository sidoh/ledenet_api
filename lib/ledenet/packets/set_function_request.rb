require 'bindata'

require 'ledenet/packets/fields/checksum'
require 'ledenet/packets/empty_response'

module LEDENET::Packets
  class SetFunctionRequest < BinData::Record
    VALID_SPEED_RANGE = (0..100)

    # Speed value is in [0x00, 0x20], with 0x00 being the fastest.
    PACKET_SPEED_RANGE = (0x00..0x20)

    hide :checksum
    mandatory_parameter :function_id
    mandatory_parameter :speed

    uint8 :packet_id, value: 0x61
    uint8 :function_id_val, value: ->() { function_id }

    uint8 :speed_val, value: ->() do
      if !VALID_SPEED_RANGE.include?(speed)
        raise "Speed should be between #{VALID_SPEED_RANGE.min} and #{VALID_SPEED_RANGE.max}"
      end

      scaled_speed = (speed / (VALID_SPEED_RANGE.max / PACKET_SPEED_RANGE.max)).round
      scaled_speed = [PACKET_SPEED_RANGE.min, scaled_speed].max
      scaled_speed = [PACKET_SPEED_RANGE.max, scaled_speed].min

      PACKET_SPEED_RANGE.max - scaled_speed
    end

    uint8 :remote_or_local, value: 0x0F
    checksum :checksum, packet_data: ->() { snapshot }

    def response_reader
      LEDENET::Packets::EmptyResponse
    end
  end
end
