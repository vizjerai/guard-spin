require 'spec_helper'

describe Guard::Zeus do

  describe '#initialize' do
    it "instantiates Runner with given options" do
      Guard::Zeus::Runner.should_receive(:new).with(:bundler => false)
      Guard::Zeus.new [], { :bundler => false }
    end
  end

  describe '.start' do
    it "calls Runner.kill_zeus and Runner.launch_zeus with 'Start'" do
      subject.runner.should_receive(:kill_zeus)
      subject.runner.should_receive(:launch_zeus).with('Start')
      subject.start
    end
  end

  describe '.reload' do
    it "calls Runner.kill_zeus and Runner.launch_zeus with 'Reload'" do
      subject.runner.should_receive(:kill_zeus)
      subject.runner.should_receive(:launch_zeus).with('Reload')
      subject.reload
    end
  end

  describe '.run_all' do
    it "calls Runner.run_all" do
      subject.runner.should_receive(:run_all)
      subject.run_all
    end
  end

  describe '.run_on_change (for guard 1.0.x and earlier)' do
    it 'calls Runner.run with file name' do
      subject.runner.should_receive(:run).with('file_name.rb')
      subject.run_on_change('file_name.rb')
    end
  end

  describe '.run_on_changes' do
    it "calls Runner.run with file name" do
      subject.runner.should_receive(:run).with('file_name.rb')
      subject.run_on_changes('file_name.rb')
    end

    it "calls Runner.run with paths" do
      subject.runner.should_receive(:run).with(['spec/controllers', 'spec/requests'])
      subject.run_on_changes(['spec/controllers', 'spec/requests'])
    end
  end

  describe '.stop' do
    it 'calls Runner.kill_zeus' do
      subject.runner.should_receive(:kill_zeus)
      subject.stop
    end
  end

end
