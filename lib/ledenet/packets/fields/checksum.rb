require 'bindata'

module LEDENET
  class Checksum < BinData::Record
    mandatory_parameter :packet_data

    uint8 :checksum, :value => ->() { packet_data.values.reduce(&:+) % 0x100 }
  end
end
