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
      runner.launch_spin("start")
    end

    def reload
      runner.kill_spin
      runner.launch_spin("reload")
    end

    def run_on_change(paths)
      runner.run(paths)
    end

    def stop
      runner.kill_spin
    end

  end
end
