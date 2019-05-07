# TODO: Write documentation for `FiberPool`

require "../job"
require "./pool.cr"
require "../logger"

module Async
  class FiberPool < Pool
    include AsyncLogger

    # Available fibers
    @available = 0
    # Jobs queue
    @jobs = Deque(GenericJob | Nil).new
    # Fibers
    @fibers = [] of Fiber

    # Global running communication
    @is_running = true
    @channel = Channel(GenericJob | Nil).new(1)

    # Global end communication
    @is_working = true
    @is_waiting_death = false
    @death_channel = Channel(Nil).new

    # Global wait communication
    @is_waiting = false
    @wait_channel = Channel(Nil).new

    private def worker
      spawn do
        @logger.info "[FiberPool#worker #{Fiber.current.object_id}] Worker launched"
        while @is_running
          if @jobs.empty?
            break unless @is_working
            @available += 1
            @wait_channel.send(nil) if @is_waiting
            job = @channel.receive.dup
          else
            job = @jobs.shift?.dup
          end
          @logger.debug "[FiberPool#worker #{Fiber.current.object_id}] Task starting..." if job
          @logger.debug "[FiberPool#worker #{Fiber.current.object_id}] Fiber awoken with nil" unless job
          break unless job
          job.call
          @logger.debug "[FiberPool#worker #{Fiber.current.object_id}] Task finished..." if job
        end
        @death_channel.send(nil) if @is_waiting_death
        @logger.info "[FiberPool#worker #{Fiber.current.object_id}] Worker killed"
      end
    end

    # Capturing any type of proc and its variadic argument in a GenericJob (equivalent of C++ std::bind)
    private def capture(callable, args)
      Job(typeof(callable), typeof(args)).new(callable, args)
    end

    # Statys of each fibers, debug purpose only
    private def status
      @fibers.each do |fiber|
        puts "[FiberPool#status] [Worker ##{fiber.object_id}] :\n\tis dead? #{fiber.dead?}\n\tis running? #{fiber.running?}\n\tis resumable? #{fiber.resumable?}"
      end
    end

    private def send_job(job)
      if @available <= 0
        @jobs.push(job)
      else
        @available -= 1
        tmp = @jobs.shift?
        if tmp != nil
          @channel.send(tmp)
          @jobs.push(job)
        else
          @channel.send(job)
        end
      end
    end

    # Launch a pool, with `nb_of_workers` workers. As it's a fiber pool, each worker is a `Fiber`
    def initialize(nb_of_workers : Int32, verbose_level = default_severity_level)
      @logger = Logger.new(STDERR, level: verbose_level)
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
      job = capture(callable, args)
      send_job(job)
      @logger.debug "[FiberPool#push] Job added in FiberPool queue"
    end

    # Wait for every jobs to finish
    #
    # NOTE: Blocking call
    def wait
      @logger.info "[FiberPool#wait] Fiber pool waiting for all jobs to finish..."
      @is_waiting = true
      while (@available < @fibers.size)
        @wait_channel.receive
      end
      @is_waiting = false
      @logger.info "[FiberPool#wait] All jobs finished!"
    end

    # Add a job to the pool, and block the execution until this job is done
    #
    # NOTE: Blocking call
    def wait_for(callable, *args)
      job = capture(callable, args)
      local_channel = Channel(Nil).new
      wrapper_proc = ->(arg : typeof(job)) do
        arg.dup.call
        local_channel.send(nil)
      end
      wrapped_job = capture(wrapper_proc, {job})
      send_job(wrapped_job)
      @logger.info "[FiberPool#wait_for] Fiber pool is waiting for #{typeof(callable)} to be executed..."
      local_channel.receive
      @logger.info "[FiberPool#wait_for] Fiber pool finished waiting for #{typeof(callable)}!"
    end

    # Tell the pool to finish all currently executed jobs, then to kill all workers
    #
    # NOTE: All the pending queued jobs won't be executed and are lost
    # NOTE: The pool is no more available after this (no worker left!)
    def stop
      @logger.info "[@FiberPool#stop] Fiber pool is finishing currently executed jobs..."
      @jobs.clear
      @fibers.size.times do
        send_job(nil)
      end
      @logger.info "[@FiberPool#stop] Fiber pool finished current jobs! It's closing, without executing pending jobs!"
    end

    # Wait for every jobs to finish, and destroy all workers
    #
    # NOTE: Blocking call
    # NOTE: The pool is no more available after this (no worker left!)
    def finish
      @logger.info "[FiberPool#finish] Finishing fiber pool..."
      @is_waiting_death = true
      @is_working = false
      @fibers.size.times do
        while (@available > 0)
          @available -= 1
          @channel.send(nil)
        end
        @death_channel.receive
      end
      @logger.info "[FiberPool#finish] Fiber pool finished!"
    end

    # Kill instantaneously all workers
    #
    # NOTE: The pool is no more available after this
    # TODO: Not implemented yet
    def terminate
      @logger.warn "[FiberPool#terminate] Terminating fiber pool!"
      @logger.error "[FiberPool#terminate] Not implemented yet!"
      # @fibers.each { |fiber| Fiber.inactive(fiber) }
      # @jobs.clear
    end

    # Finish every jobs, currently executed or pending, destroy all workers and the pool itself
    def finalize
      @logger.info "[FiberPool#finalize] Fiber pool is finishing to work in the background..."
      @is_working = false
      while (@available > 0)
        @available -= 1
        @channel.send(nil)
      end
    end
  end
end
