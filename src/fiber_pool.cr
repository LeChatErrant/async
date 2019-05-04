# TODO: Write documentation for `FiberPool`

require "./pool.cr"
require "./job.cr"
require "./async_logger.cr"

module Async
  class FiberPool < Pool
    include AsyncLogger

    @logger = Logger.new(STDERR, level: default_severity_level)
    @channel = Channel(Nil).new(1)
    @jobs = Deque(Job).new
    @fibers = [] of Fiber
    @is_running = true

    private def worker
      spawn do
        @logger.info "Fiber launched"
        while @is_running
          @channel.receive if @jobs.empty?
          @logger.debug "Task starting..."
          @jobs.shift?.dup.try &.call()
          @logger.debug "Task finished..."
        end
        @logger.info "Fiber killed"
      end
    end

    def initialize(nb_of_fibers : Int32)
      nb_of_fibers.times { @fibers.push(worker) }
    end

    def push(callable, *args)
      job = GenericJob(typeof(callable), typeof(args)).new(callable, args)
      @jobs.push(job)
      @logger.debug "Job added in FiberPool queue"
      @channel.send(nil) if @jobs.empty?
    end

    def wait
    end

    def wait_for
    end

    def stop
      @is_running = false
      @jobs.clear
      @fibers.size.times { @channel.send(nil) }
    end

    def terminate
      @fibers.each { |fiber| Fiber.inactive(fiber) }
    end

    def finalize
    end
  end
end
