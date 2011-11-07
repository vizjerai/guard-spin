module Guard
  class Spin
    class Runner
      attr_reader :options

      def initialize(options = {})
        @options = options
        UI.info "Guard::Spin Initialized"
      end

      def launch_spin(action)
        UI.info "#{action.caplitalize}ing Spin", :reset => true
        start_spin
      end

      def kill_spin
        UI.info "Killing spin", :reset => true
        stop_spin
      end

      def run(paths)
        UI.info "Running #{paths.join(" ")}", :reset => true
        system(run_command)
      end

      private

      def run_command
        "spin push #{paths.join(" ")}"
      end

      def start_spin
        system "spin serve"
      end

      def stop_spin
        socket = UNIXSocket.open(socket_file)
        socket.close
      end

      def socket_file
        key = Digest::MD5.hexdigest([Dir.pwd, 'spin-gem'].join)
        [Dir.tmpdir, key].join('/')
      end
    end
  end
end
