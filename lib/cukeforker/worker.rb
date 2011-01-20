module CukeForker
  class Worker
    attr_reader :status, :feature, :pid, :format, :out

    def initialize(feature, format, args, out)
      @feature    = feature
      @format     = format
      @extra_args = args
      @out        = File.join out, Process.pid.to_s

      FileUtils.mkdir_p(@out) unless File.exist? @out

      @status = nil
    end

    def finished?
      wait_pid, @status = Process.waitpid2(@pid, Process::WNOHANG)
      !!wait_pid
    rescue Errno::ECHILD, Errno::ESRCH
      true
    end

    def failed?
      @status.nil? || @status.exitstatus != 0
    end

    def start
      @pid = Process.fork { execute_cucumber }
    end

    def args
      args = %W[--format #{format} --out #{output_file}]
      args += @extra_args
      args << @feature

      args
    end

    def text
      "[
        #{@pid}
        #{@feature}
        #{@status.inspect}
        #{@out}
       ]"
    end

    def output_file
      File.join @out, "#{basename}.#{@format}"
    end

    def stdout
      File.join @out, "#{basename}.stdout"
    end

    def stderr
      File.join @out, "#{basename}.stderr"
    end

    private

    def execute_cucumber
      STDOUT.reopen stdout
      STDERR.reopen stderr

      failed = Cucumber::Cli::Main.execute args
      exit failed ? 1 : 0
    end

    def basename
      @basename ||= @feature.gsub(/\W/, '_')
    end
  end # Worker
end # CukeForker
