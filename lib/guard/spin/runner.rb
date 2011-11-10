# Needed for socket_file
require 'socket'
require 'tempfile'
require 'digest/md5'

module Guard
  class Spin
    class Runner
      attr_reader :options

      def initialize(options = {})
        @options = options
        UI.info "Guard::Spin Initialized"
      end

      def launch_spin(action)
        UI.info "#{action}ing Spin", :reset => true
        spawn_spin
      end

      def kill_spin
        stop_spin
      end

      def run(paths)
        system "spin push #{paths.join(" ")}"
      end

      def run_all
        run(['spec'])
      end

      private

      def spawn_spin
        @spin_pid = fork do
          exec spin_serve_command
        end
      end

      def stop_spin
        return unless @spin_pid

        Process.kill(:INT, @spin_pid)
        sleep 0.5

        begin
          unless Process.waitpid(@spin_pid, Process::WNOHANG)
            Process.kill(:KILL, @spin_pid)
          end
        rescue Errno::ECHILD
        end
        UI.info "Spin Stopped", :reset => true
      end

      def spin_serve_command
        cmd_parts = []
        cmd_parts << "bundle exec" if bundler?
        cmd_parts << "spin serve"
        
        cmd_parts << "-Itest" if test_unit?

        cmd_parts.join(' ')
      end

      def bundler?
        @bundler ||= File.exist?("#{Dir.pwd}/Gemfile") && options[:bundler] != false
      end
      
      def test_unit?
        @test_unit ||= File.exist?("#{Dir.pwd}/test/test_helper.rb") && options[:test_unit] != false
      end

      def rspec?
        @rspec ||= File.exist?("#{Dir.pwd}/spec") && options[:rspec] != false
      end
    end
  end
end
