require 'ledenet/packets/set_power_request'
require 'ledenet/packets/status_request'
require 'ledenet/packets/update_color_request'

module LEDENET
  class Api
    DEFAULT_OPTIONS = {
        reuse_connection: false,
        max_retries: 3,
        port: 5577
    }

    def initialize(device_address, options = {})
      @device_address = device_address
      @options = DEFAULT_OPTIONS.merge(options)
    end

    def on
      send_packet(LEDENET::Packets::SetPowerRequest.on_request)
    end

    def off
      send_packet(LEDENET::Packets::SetPowerRequest.off_request)
    end

    def on?
      status.on?
    end

    def update_rgb(r, g, b)
      update_color_data(red: r, green: g, blue: b)
    end

    def update_warm_white(warm_white)
      update_color_data(warm_white: warm_white)
    end

    def update_color_data(o)
      updated_data = current_color_data.merge(o)
      send_packet(LEDENET::Packets::UpdateColorRequest.new(updated_data))
    end

    def current_rgb
      current_color_data.values_at(:red, :green, :blue)
    end

    def current_warm_white
      current_color_data[:warm_white]
    end

    def current_color_data
      status_response = status
      color_data = %w{red green blue warm_white}.map do |x|
        [x.to_sym, status_response.send(x)]
      end
      Hash[color_data]
    end

    def reconnect!
      create_socket
      true
    end

    def send_packet(packet)
      socket_action do
        @socket.write(packet.to_binary_s)

        if packet.response_reader != LEDENET::Packets::EmptyResponse
          packet.response_reader.read(@socket)
        end
      end
    end

    private
      def status
        send_packet(LEDENET::Packets::StatusRequest.new)
      end

      def create_socket
        @socket.close unless @socket.nil? or @socket.closed?
        @socket = TCPSocket.new(@device_address, @options[:port])
      end

      def socket_action
        tries = 0
        begin
          create_socket if @socket.nil? or @socket.closed?
          yield
        rescue Errno::EPIPE, IOError => e
          tries += 1

          if tries <= @options[:max_retries]
            reconnect!
            retry
          else
            raise e
          end
        ensure
          if !@socket.nil? && !@socket.closed? && !@options[:reuse_connection]
            @socket.close
          end
        end
      end
  end
end
