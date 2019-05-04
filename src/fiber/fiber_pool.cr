# TODO: Write documentation for `FiberPool`

require "../pool.cr"
require "../job.cr"
require "../async_logger.cr"

module Async
  class FiberPool < Pool
    include AsyncLogger

    @logger = Logger.new(STDERR, level: default_severity_level)
    @jobs = Deque(Job).new
    @fibers = [] of Fiber

    @is_running = true
    @channel = Channel(Nil).new(1)

    @is_working = true
    @death_channel = Channel(Nil).new

    @is_waiting = false
    @wait_channel = Channel(Nil).new

    private def worker
      spawn do
        @logger.info "Fiber launched"
        while @is_running
          if @jobs.empty?
            @wait_channel.send(nil) if @is_waiting
            break unless @is_working
            @channel.receive
          end
          @logger.debug "Task starting..."
          @jobs.shift?.dup.try &.call()
          @logger.debug "Task finished..."
        end
        @logger.info "Fiber killed"
        @death_channel.send(nil)
      end
    end

    # Launch a pool, with `nb_of_workers` workers. As it's a fiber pool, each worker is a `Fiber`
    def initialize(nb_of_workers : Int32)
      nb_of_workers.times { @fibers.push(worker) }
    end

    # Add a job to the pool. When a worker will be available, it'll pick the job and execute it.
    #
    # `#push` takes any type of `Proc` as argument, and all the arguments to be passed to the proc when it'll be called
    #
    # Notice that your code won't compile if you forget one argument
    #
    # Proc without arguments
    # ```
    # pool.push(->{ puts "hello" })
    # ```
    #
    # Proc with arguments
    # ```
    # pool.push(->(i : Int32, str : String) { puts "#{str} : #{i}" }, 12, "Hello, number")
    # ```
    #
    # From function
    # ```
    # def welcome(name : String)
    #   puts "Hello, #{name}!"
    #   name
    # end
    #
    # welcome_proc = ->welcome(String)
    # pool.push(welcome_proc, "John")
    # # Or simply
    # pool.push(->welcome(String), "John")
    # ```
    def push(callable, *args)
      job = GenericJob(typeof(callable), typeof(args)).new(callable, args)
      @jobs.push(job)
      @logger.debug "Job added in FiberPool queue"
      @channel.send(nil) if @jobs.empty?
    end

    # Wait for every jobs to finish
    #
    # NOTE: Blocking call
    def wait
      @is_waiting = true
      @fibers.size.times { @wait_channel.receive }
      @is_waiting = false
    end

    # Add a job to the pool, and block the execution until this job is done
    #
    # NOTE: Blocking call
    # TODO: Not implemented yet
    def wait_for(callable, *args)
    end

    # Tell the pool to finish all currently executed jobs, then to kill all workers
    #
    # NOTE: All the pending queued jobs won't be executed and are lost
    # NOTE: The pool is no more available after this
    def stop
      @is_running = false
      @jobs.clear
      @fibers.size.times { @channel.send(nil) }
    end

    # Wait for every jobs to finish, and destroy all workers
    #
    # NOTE: Blocking call
    # NOTE: The pool is no more available after this
    def finish
      @is_working = false
      @fibers.size.times { @death_channel.receive }
    end

    # Kill instantaneously all workers
    #
    # NOTE: The pool is no more available after this
    # TODO: Not implemented yet
    def terminate
      # @fibers.each { |fiber| Fiber.inactive(fiber) }
      # @jobs.clear
    end

    # Finish every jobs, currently executed or pending, and destroy all workers and the pool
    def finalize
      @is_working = false
    end
  end
end
