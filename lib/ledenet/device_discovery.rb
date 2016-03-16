require 'socket'
require 'timeout'
require 'set'

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

  DEFAULT_OPTIONS = {
      expected_devices: 1,
      timeout: 5,
      expected_models: []
  }

  # The WiFi controllers these things appear to use support a discovery protocol
  # roughly outlined here: http://www.usriot.com/Faq/49.html
  #
  # A "password" is sent over broadcast port 48899. We can respect replies
  # containing IP address, hardware address, and model number. The model number
  # appears to correspond to the WiFi controller, and not the LED controller
  # itself.
  def self.discover_devices(options = {})
    options = DEFAULT_OPTIONS.merge(options)

    send_addr = ['<broadcast>', 48899]
    send_socket = UDPSocket.new
    send_socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, true)
    send_socket.send('HF-A11ASSISTHREAD', 0, send_addr[0], send_addr[1])

    discovered_devices = []
    discovered_models = Set.new
    expected_models = Set.new(options[:expected_models])

    begin
      Timeout::timeout(options[:timeout]) do
        while discovered_devices.count < options[:expected_devices] or
              !expected_models.subset?(discovered_models)
          data = send_socket.recv(1024)

          device = LEDENET::Device.new(data)

          if device.ip and device.hw_addr and device.model
            discovered_devices.push(device)
            discovered_models.add(device.model)
          end
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
