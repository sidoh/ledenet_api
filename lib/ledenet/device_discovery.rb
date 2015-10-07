require 'socket'
require 'timeout'

module LEDENET
  class Device
    attr_reader :ip, :hw_addr, :model

    def initialize(device_str)
      parts = device_str.split(',')

      @ip = parts[0]
      @hw_addr = parts[1]
      @model = parts[2]
    end
  end

  # The WiFi controllers these things appear to use support a discovery protocol
  # roughly outlined here: http://www.usriot.com/Faq/49.html
  #
  # A "password" is sent over broadcast port 48899. We can respect replies
  # containing IP address, hardware address, and model number. The model number
  # appears to correspond to the WiFi controller, and not the LED controller
  # itself.
  def self.discover_devices(expected_devices = 1, timeout = 5)
    send_addr = ['<broadcast>', 48899]
    send_socket = UDPSocket.new
    send_socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, true)
    send_socket.send('HF-A11ASSISTHREAD', 0, send_addr[0], send_addr[1])

    discovered_devices = []

    begin
      Timeout::timeout(timeout) do
        while true
          data = send_socket.recv(1024)
          discovered_devices.push(LEDENET::Device.new(data))

          raise Timeout::Error if discovered_devices.count >= expected_devices
        end
      end
    rescue Timeout::Error
      # Expected
    ensure
      send_socket.close
    end

    discovered_devices
  end
end