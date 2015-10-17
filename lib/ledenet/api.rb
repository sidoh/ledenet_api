module LEDENET
  class Api
    API_PORT = 5577

    DEFAULT_OPTIONS = {
        reuse_connection: false,
        max_retries: 3
    }

    def initialize(device_address, options = {})
      @device_address = device_address
      @options = DEFAULT_OPTIONS.merge(options)
    end

    def on
      send_bytes_action(0x71, 0x23, 0x0F, 0xA3)
    end

    def off
      send_bytes_action(0x71, 0x24 ,0x0F, 0xA4)
    end

    def on?
      (status.bytes[13] & 0x01) == 1
    end

    def update_color(r, g, b)
      checksum = color_checksum(r, g, b)

      send_bytes_action(0x31, r, g, b, 0xFF, 0, 0x0F, checksum)
    end

    def current_color
      status.bytes[6, 3]
    end

    def reconnect!
      create_socket
    end

    private
      def color_checksum(r, g, b)
        (r + g + b + 0x3F) % 0x100
      end

      def status
        socket_action do
          send_bytes(0x81, 0x8A, 0x8B, 0x96)

          # Example response:
          # [129, 4, 35, 97, 33, 9, 11, 22, 33, 255, 3, 0, 0, 119]
          #                         R   G   B   WW            ^--- LSB indicates on/off
          flush_response(14)
        end
      end

      def flush_response(msg_length)
        @socket.recv(msg_length, Socket::MSG_WAITALL)
      end

      def send_bytes(*b)
        @socket.write(b.pack('c*'))
      end

      def send_bytes_action(*b)
        socket_action { send_bytes(*b) }
      end

      def create_socket
        @socket.close unless @socket.nil? or @socket.closed?
        @socket = TCPSocket.new(@device_address, API_PORT)
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
          @socket.close unless @socket.closed? or @options[:reuse_connection]
        end
      end
  end
end