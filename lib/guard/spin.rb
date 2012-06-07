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

    def stop
      runner.kill_spin
    end

  end
end
