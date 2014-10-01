module CukeForker
  class Worker
    include Observable

    class << self
      attr_writer :id
      def id; @id ||= -1; end
    end

    attr_reader :status, :feature, :pid, :format, :out, :id, :data

    def initialize(feature, format, out, extra_args = [])
      @feature      = feature
      @format       = format
      @extra_args   = extra_args
      @out          = out
      @status       = nil
      @data         = OpenStruct.new

      @id = self.class.id += 1
    end

    def finished?
      wait_pid, @status = Process.waitpid2(pid, Process::WNOHANG)
      !!wait_pid
    rescue Errno::ECHILD, Errno::ESRCH
      true
    end

    def failed?
      status.nil? || status.exitstatus != 0
    end

    def start
      @pid = Process.fork {
        # make sure all workers die if cukeforker is killed
        Process.setpgid 0, 0

        changed
        notify_observers :on_worker_forked, self
        execute_cucumber
      }
    end

    def args
      args = Array(format).flat_map { |f| %W[--format #{f} --out #{output(f)}] }
      args += @extra_args
      args << feature
      args
    end

    def text
      "[
        #{pid}
        #{feature}
        #{status.inspect}
        #{out}
        #{data}
       ]"
    end

    def output(format=nil)
      format = @format if format.nil?
      File.join out, "#{basename}.#{format}"
    end

    def stdout
      File.join out, "#{basename}.stdout"
    end

    def stderr
      File.join out, "#{basename}.stderr"
    end

    def basename
      @basename ||= feature.gsub(/\W/, '_')
    end

    def kill
      return unless pid

      Process.kill("INT", pid)
      Process.wait(pid)
    rescue
      # could not kill worker, ignore
    end

    private

    def execute_cucumber
      FileUtils.mkdir_p(out) unless File.exist? out

      $stdout.reopen stdout
      $stderr.reopen stderr

      failed = Cucumber::Cli::Main.execute args

      $stdout.flush
      $stderr.flush

      exit failed ? 1 : 0
    end

  end # Worker
end # CukeForker
