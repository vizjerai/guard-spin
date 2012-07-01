require 'guard'
require 'guard/guard'

module Guard
  class Spin < Guard

    autoload :Runner, 'guard/spin/runner'
    attr_accessor :runner

    def initialize(watchers=[], options={})
      super
      @runner = Runner.new(options)
    end

    def start
      runner.kill_spin
      runner.launch_spin("Start")
    end

    def reload
      runner.kill_spin
      runner.launch_spin("Reload")
    end

    def run_all
      runner.run_all
    end

    def run_on_changes(paths)
      runner.run(paths)
    end
    # for guard 1.0.x and earlier
    alias :run_on_change :run_on_changes

    def stop
      runner.kill_spin
    end

    def respond_to?(name)
      if name == :run_on_change
        false
      else
        super
      end
    end
  end
end
