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
        spawn_spin spin_serve_command, spin_serve_options
      end

      def kill_spin
        stop_spin
      end

      def run(paths)
        run_command spin_push_command(paths), spin_push_options
      end

      def run_all
        if rspec?
          run(['spec'])
        elsif test_unit?
          run(['test'])
        end
      end

      private

      def run_command(cmd, options = '')
        system "#{cmd} #{options}"
      end

      def spawn_spin(cmd, options = '')
        @spin_pid = fork do
          exec "#{cmd} #{options}"
        end
      end

      def stop_spin
        return unless @spin_pid

        Process.kill(:INT, @spin_pid)

        begin
          unless Process.waitpid(@spin_pid, Process::WNOHANG)
            Process.kill(:KILL, @spin_pid)
          end
        rescue Errno::ECHILD
        end
        UI.info "Spin Stopped", :reset => true
      end

      def spin_push_command(paths)
        cmd_parts = []
        cmd_parts << "bundle exec" if bundler?
        cmd_parts << "spin push"
        cmd_parts << paths.join(' ')
        cmd_parts.join(' ')
      end

      def spin_push_options
        ''
      end

      def spin_serve_command
        cmd_parts = []
        cmd_parts << "bundle exec" if bundler?
        cmd_parts << "spin serve"
        cmd_parts.join(' ')
      end

      def spin_serve_options
        opt_parts = []
        opt_parts << "-Itest" if test_unit?
        opt_parts.join(' ')
      end

      def bundler?
        @bundler ||= options[:bundler] != false && File.exist?("#{Dir.pwd}/Gemfile")
      end

      def test_unit?
        @test_unit ||= options[:test_unit] != false && File.exist?("#{Dir.pwd}/test/test_helper.rb")
      end

      def rspec?
        @rspec ||= options[:rspec] != false && File.exist?("#{Dir.pwd}/spec")
      end
    end
  end
end
