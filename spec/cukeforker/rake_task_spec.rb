require File.expand_path("../../spec_helper", __FILE__)

require 'cukeforker/rake_task'

describe CukeForker::RakeTask do
  describe 'define task' do
    it 'creates a cukeforker task' do
      CukeForker::RakeTask.new

      expect(Rake::Task.task_defined?(:cukeforker)).to be true
    end

    it 'creates a named task' do
      CukeForker::RakeTask.new(:run_feature)

      expect(Rake::Task.task_defined?(:run_feature)).to be true
    end
  end

  describe 'running task' do
    before(:each) do
      Rake::Task['cukeforker'].clear if Rake::Task.task_defined?('cukeforker')
    end

    it 'runs specific features' do
      CukeForker::RakeTask.new do |task|
        task.features = ['file1, file2']
        task.verbose = false
      end

      expect(CukeForker::Runner).to receive(:run).and_return(true)

      Rake::Task['cukeforker'].execute
    end

    it 'exits with a non zero status if any tests fail' do
      CukeForker::RakeTask.new do |task|
        task.features = ['file1, file2']
        task.verbose = false
      end

      expect(CukeForker::Runner).to receive(:run).and_return(false)

      expect { Rake::Task['cukeforker'].execute }.to raise_error(Exception)
    end
  end
end
