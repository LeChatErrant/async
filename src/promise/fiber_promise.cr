require "./promise.cr"
require "../job"
require "../return_value"
require "../logger"
require "../function"

module Async
  # abstract class GenericProc
  #   abstract def initialize(callable)
  #   abstract def call
  # end
  # class MyProc(T) < GenericProc
  #   def initialize(@callable : T)
  #   end
  #   def call(*args)
  #     @callable.call *args
  #   end
  # end

  class FiberPromise < Promise
    include AsyncLogger

    @state = PromiseState::PENDING
    @is_waiting = false
    @channel = Channel(Nil).new
    @return_value : GenericReturnValue = ReturnValue(Nil).new(nil)

    # Capturing any type of proc and its variadic argument in a GenericJob (equivalent of C++ std::bind)
    private def capture(callable, args)
      Job(typeof(callable), typeof(args)).new(callable, args)
    end

    def initialize(callable, *args)
      job = capture(callable, args)
      spawn do
        tmp = job.call
        @return_value = ReturnValue(typeof(tmp)).new(tmp)
        @state = PromiseState::RESOLVED
      rescue e
        @return_value = ReturnValue(typeof(e)).new(e)
        @state = PromiseState::REJECTED
      ensure
        @channel.send(nil) if @is_waiting
      end
    end

    def wait
      if state != PromiseState::PENDING
        @return_value.get
      else
        @is_waiting = true
        @channel.receive
        @return_value.try &.get
      end
    end

    def get
      if state != PromiseState::PENDING
        @return_value.get
      else
        @state
      end
    end

    def then(callable)
      #      @then = MyProc(typeof(callable)).new(callable)
      # @then = capture(callable, {nil})
    end

    def catch(callable : T) forall T
      #      @catch = Function(typeof(callable)).new(callable)
      FiberPromise.new(->(this : self, callback : T) do
        value = await this
#        callable.call value
      end, self, callable)
    end

    def finally(callable)
    end

    def to_s(io : IO) : Nil
      io << "#<Async::FiberPromise:#{self.object_id}> #{@state}"
    end

    def state
      @state
    end
  end
end
