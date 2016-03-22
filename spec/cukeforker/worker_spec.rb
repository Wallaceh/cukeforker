require File.expand_path("../../spec_helper", __FILE__)

module CukeForker

  describe Worker do
    let(:worker) { Worker.new("some/feature", :json, "some/path", %w[--extra args]) }

    before {
      FileUtils.stub :mkdir_p
    }

    context "running a scenario on specific line" do
      let(:worker) { Worker.new("some/feature:51", :json, "some/path", %w[--extra args]) }

      it "has an output file that includes the line number in its name" do
        worker.output.should == "some/path/some_feature_51.json"
      end

      it "has a stdout file that includes the line number in its name" do
        worker.stdout.should == "some/path/some_feature_51.stdout"
      end

      it "has a stderr file that includes the line number in its name" do
        worker.stderr.should == "some/path/some_feature_51.stderr"
      end
    end

    context "running a scenario with multiple report formats" do
      formats = [:json, :junit]
      path = "some/path"
      let(:worker) { Worker.new("some/feature:51", formats, path) }

      it "has an output file for each format specified" do
        expected_args = formats.flat_map do |f|
          %W[--format #{f} --out #{path}/some_feature_51.#{f}]
        end
        worker.args.each_cons(expected_args.size).include?(expected_args).should be_truthy
      end
    end

    it "creates an argument string based on the given parameters" do
      worker.args.should == %w{--format json --out some/path/some_feature.json --extra args some/feature }
    end

    it "has an output file" do
      worker.output.should == "some/path/some_feature.json"
    end

    it "has a stdout file" do
      worker.stdout.should == "some/path/some_feature.stdout"
    end

    it "has a stderr file" do
      worker.stderr.should == "some/path/some_feature.stderr"
    end

    it "has a text representation" do
      worker.text.should include("some/feature")
    end

    it "runs a passing cuke and exits with 0" do
      Process.should_receive(:fork).and_yield.and_return(1234)
      Process.should_receive(:setpgid).with(0, 0)

      $stdout.should_receive(:reopen).with("some/path/some_feature.stdout")
      $stderr.should_receive(:reopen).with("some/path/some_feature.stderr")

      Cucumber::Cli::Main.should_receive(:execute).and_return(false)
      worker.should_receive(:exit).with(0)

      worker.start
    end

    it "runs a failing cuke and exits with 1" do
      Process.should_receive(:fork).and_yield.and_return(1234)
      Process.should_receive(:setpgid).with(0, 0)

      $stdout.should_receive(:reopen).with("some/path/some_feature.stdout")
      $stderr.should_receive(:reopen).with("some/path/some_feature.stderr")

      Cucumber::Cli::Main.should_receive(:execute).and_return(true)
      worker.should_receive(:exit).with(1)

      worker.start
    end

    it "fires an event after forking" do
      mock_listener = double(AbstractListener)
      mock_listener.should_receive(:update).with(:on_worker_forked, worker)

      worker.add_observer mock_listener

      Process.should_receive(:fork).and_yield.and_return(1234)
      $stdout.should_receive(:reopen).with("some/path/some_feature.stdout")
      $stderr.should_receive(:reopen).with("some/path/some_feature.stderr")
      Cucumber::Cli::Main.should_receive(:execute).and_return(false)
      worker.should_receive(:exit).with(0)

      worker.start
    end

    it "considers itself failed if status wasn't collected" do
      worker.stub :status => nil
      worker.should be_failed
    end

    it "considers itself failed if the exit code was 1" do
      worker.stub :status => double(:exitstatus => 1)
      worker.should be_failed
    end

    it "considers itself failed  if the exit code was 0" do
      worker.stub :status => double(:exitstatus => 0)
      worker.should_not be_failed
    end

    it "knows if the child is still running" do
      Process.stub :waitpid2 => nil
      worker.should_not be_finished
    end

    it "knows if the child is finished" do
      Process.stub :waitpid2 => [1234, :some_status]
      worker.should be_finished
      worker.status.should == :some_status
    end

    it "knows if the child has already been reaped" do
      Process.stub(:waitpid2).and_raise(Errno::ECHILD)
      worker.should be_finished

      Process.stub(:waitpid2).and_raise(Errno::ESRCH)
      worker.should be_finished
    end

    it "can kill the child process" do
      worker.stub(:pid => $$)

      Process.should_receive(:kill)
      Process.should_receive(:wait)

      worker.kill
    end

    it "ignores failures when killing the child" do
      worker.stub(:pid => $$)

      Process.should_receive(:kill).and_raise(Errno::ECHILD)
      worker.kill.should be_nil
    end

  end # Worker
end # CukeForker
