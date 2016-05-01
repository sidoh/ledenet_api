require 'ledenet/packets/set_power_request'
require 'ledenet/packets/status_request'
require 'ledenet/packets/update_color_request'
require 'ledenet/packets/set_function_request'

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

    def status
      response = request_status
      status = { is_on: on?(response) }
      status.merge!(current_color_data(response))
      status.merge!(current_function_data(response))
    end

    def on
      send_packet(LEDENET::Packets::SetPowerRequest.on_request)
    end

    def off
      send_packet(LEDENET::Packets::SetPowerRequest.off_request)
    end

    def set_power(v)
      v ? on : off
    end

    def on?(response = request_status)
      response.on?
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

    def current_color_data(response = request_status)
      select_status_keys(response, *%w{red green blue warm_white})
    end

    def update_function(fn)
      if fn.is_a?(String) or fn.is_a?(Symbol)
        fn = LEDENET::Functions.const_get(fn.upcase)
      end
      update_function_data(function_id: fn)
    end

    def update_function_speed(s)
      update_function_data(speed: s)
    end

    def update_function_data(o)
      o = {}.merge(o)
      current_data = current_function_data
      updated_data = {
        function_id: current_data[:function_id],
        speed: current_data[:speed_packet_value]
      }

      if o[:speed]
        speed = LEDENET::FunctionSpeed.from_value(o.delete(:speed))
        updated_data[:speed] = speed.packet_value
      end
      updated_data.merge!(o)

      send_packet(LEDENET::Packets::SetFunctionRequest.new(updated_data))
    end

    def current_function_data(response = request_status)
      raw_function_data = select_status_keys(response, *%w{mode speed})
      function_data = {
        running_function?: raw_function_data[:mode] != LEDENET::Functions::NO_FUNCTION,
        speed: FunctionSpeed.from_packet_value(raw_function_data[:speed]).value,
        speed_packet_value: raw_function_data[:speed],
        function_name: LEDENET::Functions.value_of(raw_function_data[:mode]),
        function_id: raw_function_data[:mode]
      }
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
      def select_status_keys(status_response, *keys)
        color_data = keys.map do |x|
          [x.to_sym, status_response.send(x)]
        end
        Hash[color_data]
      end

      def request_status
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
