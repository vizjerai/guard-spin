require 'guard'
require 'guard/guard'

module Guard
  class Zeus < Guard

    autoload :Runner, 'guard/zeus/runner'
    attr_accessor :runner

    def initialize(watchers=[], options={})
      super
      @runner = Runner.new(options)
    end

    def start
      runner.kill_zeus
      runner.launch_zeus("Start")
    end

    def reload
      runner.kill_zeus
      runner.launch_zeus("Reload")
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
      runner.kill_zeus
    end

  end
end
