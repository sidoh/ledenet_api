module LEDENET
  class FunctionSpeed
    # Speed range exposed through API
    INTERFACE_SPEED_RANGE = (1..100)

    # Speed value is in [0x01, 0x1F], with 0x00 being the fastest.
    PACKET_SPEED_RANGE = (0x01..0x1F)

    attr_reader :value

    def initialize(value)
      @value = value
    end

    def packet_value
      FunctionSpeed.convert_range(value, INTERFACE_SPEED_RANGE, PACKET_SPEED_RANGE)
    end

    def self.from_value(value)
      FunctionSpeed.new(value)
    end

    def self.from_packet_value(value)
      v = FunctionSpeed.convert_range(value, PACKET_SPEED_RANGE, INTERFACE_SPEED_RANGE)
      FunctionSpeed.new(v)
    end

    private
      def self.convert_range(value, from, to)
        scaled_speed = (value / (from.max.to_f / to.max)).round
        scaled_speed = [to.min, scaled_speed].max
        scaled_speed = [to.max, scaled_speed].min
        to.max - scaled_speed
      end
  end
end
