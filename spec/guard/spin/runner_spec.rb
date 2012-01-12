require 'spec_helper'

describe Guard::Spin::Runner do

  describe '#initialize' do
    it 'default options are {}' do
      subject.options.should == {}
    end
  end

  describe '.launch_spin' do
    context 'with cli option' do
      subject { Guard::Spin::Runner.new :cli => '--time' }

      before do
        subject.should_receive(:test_unit?).any_number_of_times.and_return(false)
        subject.should_receive(:rspec?).any_number_of_times.and_return(true)
        subject.should_receive(:bundler?).any_number_of_times.and_return(false)
      end

      it "launches spin server with cli options" do
        subject.should_receive(:spawn_spin).with("spin serve", "--time")
        subject.launch_spin('Start')
      end
    end

    context 'with Test::Unit only' do
      before do
        subject.should_receive(:test_unit?).any_number_of_times.and_return(true)
        subject.should_receive(:rspec?).any_number_of_times.and_return(false)
        subject.should_receive(:bundler?).any_number_of_times.and_return(false)
      end

      it "launches Spin server for Test::Unit" do
        subject.should_receive(:spawn_spin).with("spin serve", "-Itest")
        subject.launch_spin('Start')
      end
    end

    context 'with Test::Unit and Bundler' do
      before do
        subject.should_receive(:test_unit?).any_number_of_times.and_return(true)
        subject.should_receive(:rspec?).any_number_of_times.and_return(false)
        subject.should_receive(:bundler?).any_number_of_times.and_return(true)
      end

      it "launches Spin server for Test::Unit with 'bundle exec'" do
        subject.should_receive(:spawn_spin).with("bundle exec spin serve", "-Itest")
        subject.launch_spin('Start')
      end
    end

    context 'with RSpec only' do
      before do
        subject.should_receive(:test_unit?).any_number_of_times.and_return(false)
        subject.should_receive(:rspec?).any_number_of_times.and_return(true)
        subject.should_receive(:bundler?).any_number_of_times.and_return(false)
      end

      it "launches Spin server for RSpec" do
        subject.should_receive(:spawn_spin).with("spin serve", "")
        subject.launch_spin('Start')
      end
    end

    context 'with Rspec and Bundler' do
      before do
        subject.should_receive(:test_unit?).any_number_of_times.and_return(false)
        subject.should_receive(:rspec?).any_number_of_times.and_return(true)
        subject.should_receive(:bundler?).any_number_of_times.and_return(true)
      end

      it "launches Spin server for RSpec with 'bundle exec'" do
        subject.should_receive(:spawn_spin).with("bundle exec spin serve", "")
        subject.launch_spin('Start')
      end
    end
  end

  describe '.kill_spin' do
    it 'not call Process#kill with no spin_id' do
      Process.should_not_receive(:kill)
      subject.kill_spin
    end

    it "calls Process#kill with 'INT, pid'" do
      subject.should_receive(:fork).and_return(123)
      subject.send(:spawn_spin, '')

      Process.should_receive(:kill).with(:INT, 123)
      Process.should_receive(:waitpid).with(123, Process::WNOHANG).and_return(123)
      Process.should_not_receive(:kill).with(:KILL, 123)
      subject.kill_spin
    end

    it "calls Process#kill with 'KILL, pid' if Process.waitpid returns nil" do
      subject.should_receive(:fork).and_return(123)
      subject.send(:spawn_spin, '')

      Process.should_receive(:kill).with(:INT, 123)
      Process.should_receive(:waitpid).with(123, Process::WNOHANG).and_return(nil)
      Process.should_receive(:kill).with(:KILL, 123)
      subject.kill_spin
    end

    it 'calls rescue when Process.waitpid raises Errno::ECHILD' do
      subject.should_receive(:fork).and_return(123)
      subject.send(:spawn_spin, '')

      Process.should_receive(:kill).with(:INT, 123)
      Process.should_receive(:waitpid).with(123, Process::WNOHANG).and_raise(Errno::ECHILD)
      Process.should_not_receive(:kill).with(:KILL, 123)
      subject.kill_spin
    end
  end

  describe '.run' do
    context 'with Bundler' do
      before do
        subject.should_receive(:bundler?).and_return(true)
      end

      it 'pushes path to spin' do
        subject.should_receive(:run_command).with('bundle exec spin push spec', '')
        subject.run(['spec'])
      end
    end

    context 'without Bundler' do
      before do
        subject.should_receive(:bundler?).and_return(false)
      end

      it 'pushes path to spin' do
        subject.should_receive(:run_command).with('spin push spec', '')
        subject.run(['spec'])
      end
    end
  end

  describe '.run_all' do
    context 'with rspec' do
      it "calls Runner.run with 'spec'" do
        subject.stub(:rspec?).and_return(true)
        subject.stub(:test_unit?).and_return(false)
        subject.should_receive(:run).with(['spec'])
        subject.run_all
      end
    end

    context 'with test_unit' do
      before do
        Dir.should_receive(:[]).with('test/**/*_test.rb').once.and_return(%w{test/unit/foo_test.rb test/functional/bar_test.rb})
        Dir.should_receive(:[]).with('test/**/test_*.rb').once.and_return(['test/unit/test_baz.rb'])
      end
      
      it "calls Runner.run with each test file" do
        subject.stub(:rspec?).and_return(false)
        subject.stub(:test_unit?).and_return(true)
        subject.should_receive(:run).with(%w{test/unit/foo_test.rb test/functional/bar_test.rb test/unit/test_baz.rb})
        subject.run_all
      end
    end

    context 'with neither' do
      it 'not call Runner.run' do
        subject.stub(:rspec?).and_return(false)
        subject.stub(:test_unit?).and_return(false)
        subject.should_not_receive(:run)
        subject.run_all
      end
    end
  end

  describe '.bundler?' do
    before do
      Dir.stub(:pwd).and_return("")
    end

    context 'with no bundler option' do
      subject { Guard::Spin::Runner.new }

      context 'with Gemfile' do
        before do
          File.should_receive(:exist?).with('/Gemfile').and_return(true)
        end

        it 'return true' do
          subject.send(:bundler?).should be_true
        end
      end

      context 'with no Gemfile' do
        before do
          File.should_receive(:exist?).with('/Gemfile').and_return(false)
        end

        it 'return false' do
          subject.send(:bundler?).should be_false
        end
      end
    end

    context 'with :bundler => false' do
      subject { Guard::Spin::Runner.new :bundler => false }

      context 'with Gemfile' do
        before do
          File.should_not_receive(:exist?)
        end

        it 'return false' do
          subject.send(:bundler?).should be_false
        end
      end

      context 'with no Gemfile' do
        before do
          File.should_not_receive(:exist?)
        end

        it 'return false' do
          subject.send(:bundler?).should be_false
        end
      end
    end

    context 'with :bundler => true' do
      subject { Guard::Spin::Runner.new :bundler => true }

      context 'with Gemfile' do
        before do
          File.should_receive(:exist?).with('/Gemfile').and_return(true)
        end

        it 'return true' do
          subject.send(:bundler?).should be_true
        end
      end

      context 'with no Gemfile' do
        before do
          File.should_receive(:exist?).with('/Gemfile').and_return(false)
        end

        it 'return false' do
          subject.send(:bundler?).should be_false
        end
      end
    end
  end

  describe '.test_unit?' do
    before do
      Dir.stub(:pwd).and_return("")
    end

    context 'with no test_unit option' do
      subject { Guard::Spin::Runner.new }

      context 'with Gemfile' do
        before do
          File.should_receive(:exist?).with('/test/test_helper.rb').and_return(true)
        end

        it 'return true' do
          subject.send(:test_unit?).should be_true
        end
      end

      context 'with no Gemfile' do
        before do
          File.should_receive(:exist?).with('/test/test_helper.rb').and_return(false)
        end

        it 'return false' do
          subject.send(:test_unit?).should be_false
        end
      end
    end

    context 'with :test_unit => false' do
      subject { Guard::Spin::Runner.new :test_unit => false }

      context 'with Gemfile' do
        before do
          File.should_not_receive(:exist?)
        end

        it 'return false' do
          subject.send(:test_unit?).should be_false
        end
      end

      context 'with no Gemfile' do
        before do
          File.should_not_receive(:exist?)
        end

        it 'return false' do
          subject.send(:test_unit?).should be_false
        end
      end
    end

    context 'with :test_unit => true' do
      subject { Guard::Spin::Runner.new :test_unit => true }

      context 'with Gemfile' do
        before do
          File.should_receive(:exist?).with('/test/test_helper.rb').and_return(true)
        end

        it 'return true' do
          subject.send(:test_unit?).should be_true
        end
      end

      context 'with no Gemfile' do
        before do
          File.should_receive(:exist?).with('/test/test_helper.rb').and_return(false)
        end

        it 'return false' do
          subject.send(:test_unit?).should be_false
        end
      end
    end
  end

  describe '.rspec?' do
    before do
      Dir.stub(:pwd).and_return("")
    end

    context 'with no rspec option' do
      subject { Guard::Spin::Runner.new }

      context 'with Gemfile' do
        before do
          File.should_receive(:exist?).with('/spec').and_return(true)
        end

        it 'return true' do
          subject.send(:rspec?).should be_true
        end
      end

      context 'with no Gemfile' do
        before do
          File.should_receive(:exist?).with('/spec').and_return(false)
        end

        it 'return false' do
          subject.send(:rspec?).should be_false
        end
      end
    end

    context 'with :rspec => false' do
      subject { Guard::Spin::Runner.new :rspec => false }

      context 'with Gemfile' do
        before do
          File.should_not_receive(:exist?)
        end

        it 'return false' do
          subject.send(:rspec?).should be_false
        end
      end

      context 'with no Gemfile' do
        before do
          File.should_not_receive(:exist?)
        end

        it 'return false' do
          subject.send(:rspec?).should be_false
        end
      end
    end

    context 'with :rspec => true' do
      subject { Guard::Spin::Runner.new :rspec => true }

      context 'with Gemfile' do
        before do
          File.should_receive(:exist?).with('/spec').and_return(true)
        end

        it 'return true' do
          subject.send(:rspec?).should be_true
        end
      end

      context 'with no Gemfile' do
        before do
          File.should_receive(:exist?).with('/spec').and_return(false)
        end

        it 'return false' do
          subject.send(:rspec?).should be_false
        end
      end
    end
  end

end
