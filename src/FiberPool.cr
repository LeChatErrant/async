# TODO: Write documentation for `FiberPool`

require "logger"

module FiberPool
  VERSION = "0.1.0"

  class FiberPool(T)

    macro default_severity_level
      {% if flag?(:release) %}
      Logger::ERROR
      {% else %}
      Logger::INFO
      {% end %}
    end

    getter logger = Logger.new(STDERR, level: default_severity_level)
    @channel = Channel(Nil).new
    @jobs = Deque(Tuple(Proc(T, Nil), T)).new

    def worker
      spawn do
        logger.info "Fiber launched"
        loop do
          @channel.receive
          logger.debug "Task starting..."
          job = @jobs.shift
          job[0].call(job[1])
          logger.debug "Task finished..."
        end
        logger.info "Fiber killed"
      end
    end

    def initialize(nb_of_fibers : Int32)
      puts typeof(@jobs)
      nb_of_fibers.times { worker }
    end


    def finalize
    end

    def job(args)
      yield *args
      puts "hello"
    end

    def add_job(*args, &block : T -> Nil)
      @jobs.push({block, args})
      logger.debug "Job pushed"
      @channel.send(nil)
    end

    def size()
      @jobs.size
    end

    # Change the level of severity beyond which the logger of your `FTPServer` will print logs
    #
    # NOTE: When building in release mode, the severity is by default at Logger::ERROR. Otherwise, it is set by default at Logger::INFO
    def verbose_level=(level : Logger::Severity)
      logger.level = level
    end

  end
end
