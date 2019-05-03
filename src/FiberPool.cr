# TODO: Write documentation for `FiberPool`

require "./Pool.cr"
require "./Job.cr"
require "./AsynCrystalLogger.cr"

module AsynCrystal

  class FiberPool

    include AsynCrystalLogger

    @logger = Logger.new(STDERR, level: default_severity_level)
    @channel = Channel(Nil).new(1)
    @jobs = Deque(Job).new
    @fibers = [] of Fiber

    private def worker
      spawn do
        @logger.info "Fiber launched"
        loop do
          @channel.receive if @jobs.empty?
          @logger.debug "Task starting..."
          @jobs.shift?().dup.try &.call()
          @logger.debug "Task finished..."
        end
        @logger.info "Fiber killed"
      end
    end

    def initialize(nb_of_fibers : Int32)
      nb_of_fibers.times { @fibers.push(worker) }
    end

    def finalize

    end

    def push(callable, *args)
      job = GenericJob(typeof(callable), typeof(args)).new(callable, args)
      @jobs.push(job)
      @logger.debug "Job added in FiberPool queue"
      @channel.send(nil) if @jobs.empty?
    end

  end
end
