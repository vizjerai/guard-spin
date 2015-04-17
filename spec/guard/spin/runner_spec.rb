require 'spec_helper'

describe Guard::Spin::Runner do
  let(:runner) { Guard::Spin::Runner.new }

  describe '#initialize' do
    subject { runner.options }

    context 'with default options' do
      it { is_expected.to eq({:run_all => true}) }
    end

    context 'with run_all => false' do
      let(:runner) { Guard::Spin::Runner.new :run_all => false }
      it { is_expected.to eq({:run_all => false}) }
    end
  end

  describe '.launch_spin' do
    context 'with cli option' do
      subject { Guard::Spin::Runner.new :cli => '--time' }

      before do
        allow(subject).to receive(:test_unit?).and_return(false)
        allow(subject).to receive(:rspec?).and_return(true)
        allow(subject).to receive(:bundler?).and_return(false)
      end

      it "launches spin server with cli options" do
        expect(subject).to receive(:spawn_spin).with("spin serve", "--time")
        subject.launch_spin('Start')
      end
    end

    context 'with Test::Unit only' do
      before do
        allow(subject).to receive(:test_unit?).and_return(true)
        allow(subject).to receive(:rspec?).and_return(false)
        allow(subject).to receive(:bundler?).and_return(false)
      end

      it "launches Spin server for Test::Unit" do
        expect(subject).to receive(:spawn_spin).with("spin serve", "-Itest")
        subject.launch_spin('Start')
      end
    end

    context 'with Test::Unit and Bundler' do
      before do
        allow(subject).to receive(:test_unit?).and_return(true)
        allow(subject).to receive(:rspec?).and_return(false)
        allow(subject).to receive(:bundler?).and_return(true)
      end

      it "launches Spin server for Test::Unit with 'bundle exec'" do
        expect(subject).to receive(:spawn_spin).with("bundle exec spin serve", "-Itest")
        subject.launch_spin('Start')
      end
    end

    context 'with RSpec only' do
      before do
        allow(subject).to receive(:test_unit?).and_return(false)
        allow(subject).to receive(:rspec?).and_return(true)
        allow(subject).to receive(:bundler?).and_return(false)
      end

      it "launches Spin server for RSpec" do
        expect(subject).to receive(:spawn_spin).with("spin serve", "")
        subject.launch_spin('Start')
      end
    end

    context 'with Rspec and Bundler' do
      before do
        allow(subject).to receive(:test_unit?).and_return(false)
        allow(subject).to receive(:rspec?).and_return(true)
        allow(subject).to receive(:bundler?).and_return(true)
      end

      it "launches Spin server for RSpec with 'bundle exec'" do
        expect(subject).to receive(:spawn_spin).with("bundle exec spin serve", "")
        subject.launch_spin('Start')
      end
    end
  end

  describe '.kill_spin' do
    it 'not call Process#kill with no spin_id' do
      expect(Process).not_to receive(:kill)
      subject.kill_spin
    end

    it "calls Process#kill with 'INT, pid'" do
      expect(subject).to receive(:fork).and_return(123)
      subject.send(:spawn_spin, '')

      expect(Process).to receive(:kill).with(:INT, 123)
      expect(Process).to receive(:waitpid).with(123, Process::WNOHANG).and_return(123)
      expect(Process).not_to receive(:kill).with(:KILL, 123)
      subject.kill_spin
    end

    it "calls Process#kill with 'KILL, pid' if Process.waitpid returns nil" do
      expect(subject).to receive(:fork).and_return(123)
      subject.send(:spawn_spin, '')

      expect(Process).to receive(:kill).with(:INT, 123)
      expect(Process).to receive(:waitpid).with(123, Process::WNOHANG).and_return(nil)
      expect(Process).to receive(:kill).with(:KILL, 123)
      subject.kill_spin
    end

    it 'calls rescue when Process.waitpid raises Errno::ECHILD' do
      expect(subject).to receive(:fork).and_return(123)
      subject.send(:spawn_spin, '')

      expect(Process).to receive(:kill).with(:INT, 123)
      expect(Process).to receive(:waitpid).with(123, Process::WNOHANG).and_raise(Errno::ECHILD)
      expect(Process).not_to receive(:kill).with(:KILL, 123)
      subject.kill_spin
    end
  end

  describe '.run' do
    context 'with Bundler' do
      before do
        expect(subject).to receive(:bundler?).and_return(true)
      end

      it 'pushes path to spin' do
        expect(subject).to receive(:run_command).with('bundle exec spin push spec', '')
        subject.run(['spec'])
      end
    end

    context 'without Bundler' do
      before do
        expect(subject).to receive(:bundler?).and_return(false)
      end

      it 'pushes path to spin' do
        expect(subject).to receive(:run_command).with('spin push spec', '')
        subject.run(['spec'])
      end
    end
  end

  describe '.run_all' do
    context 'with rspec' do
      it "calls Runner.run with 'spec'" do
        allow(subject).to receive(:rspec?).and_return(true)
        allow(subject).to receive(:test_unit?).and_return(false)
        expect(subject).to receive(:run).with(['spec'])
        subject.run_all
      end
    end

    context 'with test_unit' do
      before do
        expect(Dir).to receive(:[]).with('test/**/*_test.rb').once.and_return(%w{test/unit/foo_test.rb test/functional/bar_test.rb})
        expect(Dir).to receive(:[]).with('test/**/test_*.rb').once.and_return(['test/unit/test_baz.rb'])
      end

      it "calls Runner.run with each test file" do
        allow(subject).to receive(:rspec?).and_return(false)
        allow(subject).to receive(:test_unit?).and_return(true)
        expect(subject).to receive(:run).with(%w{test/unit/foo_test.rb test/functional/bar_test.rb test/unit/test_baz.rb})
        subject.run_all
      end
    end

    context 'with neither' do
      it 'not call Runner.run' do
        allow(subject).to receive(:rspec?).and_return(false)
        allow(subject).to receive(:test_unit?).and_return(false)
        expect(subject).not_to receive(:run)
        subject.run_all
      end
    end

    context 'with :run_all set to false' do
      let(:runner) { Guard::Spin::Runner.new :run_all => false }
      it 'not run all specs' do
        allow(runner).to receive(:rspec?).and_return(true)
        expect(runner).not_to receive(:run)
        runner.run_all
      end
    end
  end

  describe '.bundler?' do
    before do
      allow(Dir).to receive(:pwd).and_return("")
    end

    context 'with no bundler option' do
      subject { Guard::Spin::Runner.new }

      context 'with Gemfile' do
        before do
          expect(File).to receive(:exist?).with('/Gemfile').and_return(true)
        end

        it 'return true' do
          expect(subject.send(:bundler?)).to be_truthy
        end
      end

      context 'with no Gemfile' do
        before do
          expect(File).to receive(:exist?).with('/Gemfile').and_return(false)
        end

        it 'return false' do
          expect(subject.send(:bundler?)).to be_falsey
        end
      end
    end

    context 'with :bundler => false' do
      subject { Guard::Spin::Runner.new :bundler => false }

      context 'with Gemfile' do
        before do
          expect(File).not_to receive(:exist?)
        end

        it 'return false' do
          expect(subject.send(:bundler?)).to be_falsey
        end
      end

      context 'with no Gemfile' do
        before do
          expect(File).not_to receive(:exist?)
        end

        it 'return false' do
          expect(subject.send(:bundler?)).to be_falsey
        end
      end
    end

    context 'with :bundler => true' do
      subject { Guard::Spin::Runner.new :bundler => true }

      context 'with Gemfile' do
        before do
          expect(File).to receive(:exist?).with('/Gemfile').and_return(true)
        end

        it 'return true' do
          expect(subject.send(:bundler?)).to be_truthy
        end
      end

      context 'with no Gemfile' do
        before do
          expect(File).to receive(:exist?).with('/Gemfile').and_return(false)
        end

        it 'return false' do
          expect(subject.send(:bundler?)).to be_falsey
        end
      end
    end
  end

  describe '.test_unit?' do
    before do
      allow(Dir).to receive(:pwd).and_return("")
    end

    context 'with no test_unit option' do
      subject { Guard::Spin::Runner.new }

      context 'with Gemfile' do
        before do
          expect(File).to receive(:exist?).with('/test/test_helper.rb').and_return(true)
        end

        it 'return true' do
          expect(subject.send(:test_unit?)).to be_truthy
        end
      end

      context 'with no Gemfile' do
        before do
          expect(File).to receive(:exist?).with('/test/test_helper.rb').and_return(false)
        end

        it 'return false' do
          expect(subject.send(:test_unit?)).to be_falsey
        end
      end
    end

    context 'with :test_unit => false' do
      subject { Guard::Spin::Runner.new :test_unit => false }

      context 'with Gemfile' do
        before do
          expect(File).not_to receive(:exist?)
        end

        it 'return false' do
          expect(subject.send(:test_unit?)).to be_falsey
        end
      end

      context 'with no Gemfile' do
        before do
          expect(File).not_to receive(:exist?)
        end

        it 'return false' do
          expect(subject.send(:test_unit?)).to be_falsey
        end
      end
    end

    context 'with :test_unit => true' do
      subject { Guard::Spin::Runner.new :test_unit => true }

      context 'with Gemfile' do
        before do
          expect(File).to receive(:exist?).with('/test/test_helper.rb').and_return(true)
        end

        it 'return true' do
          expect(subject.send(:test_unit?)).to be_truthy
        end
      end

      context 'with no Gemfile' do
        before do
          expect(File).to receive(:exist?).with('/test/test_helper.rb').and_return(false)
        end

        it 'return false' do
          expect(subject.send(:test_unit?)).to be_falsey
        end
      end
    end
  end

  describe '.rspec?' do
    before do
      allow(Dir).to receive(:pwd).and_return("")
    end

    context 'with no rspec option' do
      subject { Guard::Spin::Runner.new }

      context 'with Gemfile' do
        before do
          expect(File).to receive(:exist?).with('/spec').and_return(true)
        end

        it 'return true' do
          expect(subject.send(:rspec?)).to be_truthy
        end
      end

      context 'with no Gemfile' do
        before do
          expect(File).to receive(:exist?).with('/spec').and_return(false)
        end

        it 'return false' do
          expect(subject.send(:rspec?)).to be_falsey
        end
      end
    end

    context 'with :rspec => false' do
      subject { Guard::Spin::Runner.new :rspec => false }

      context 'with Gemfile' do
        before do
          expect(File).not_to receive(:exist?)
        end

        it 'return false' do
          expect(subject.send(:rspec?)).to be_falsey
        end
      end

      context 'with no Gemfile' do
        before do
          expect(File).not_to receive(:exist?)
        end

        it 'return false' do
          expect(subject.send(:rspec?)).to be_falsey
        end
      end
    end

    context 'with :rspec => true' do
      subject { Guard::Spin::Runner.new :rspec => true }

      context 'with Gemfile' do
        before do
          expect(File).to receive(:exist?).with('/spec').and_return(true)
        end

        it 'return true' do
          expect(subject.send(:rspec?)).to be_truthy
        end
      end

      context 'with no Gemfile' do
        before do
          expect(File).to receive(:exist?).with('/spec').and_return(false)
        end

        it 'return false' do
          expect(subject.send(:rspec?)).to be_falsey
        end
      end
    end
  end

end
