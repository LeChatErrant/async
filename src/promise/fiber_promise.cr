require "./promise.cr"
require "../job"
require "../return_value"
require "../logger"

module Async
  class FiberPromise < Promise
    include AsyncLogger

    @state = PromiseState::PENDING
    @waiters : Int32 = 0
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
        # The responsability to decrease @waiters is taken by the fiber to avoid "deadlock" when the same Promise is waited from many Fibers
        while @waiters > 0
          @waiters -= 1
          @channel.send(nil)
        end
      end
    end

    def wait
      if state == PromiseState::RESOLVED
        @return_value.get
      else
        @waiters += 1
        @channel.receive
        @return_value.get
      end
    end

    def get
      if state == PromiseState::RESOLVED
        @return_value.get
      else
        @state
      end
    end

    def then(callable, *args)
      capture(callable, args)
      self
    end

    def catch
    end

    def resolve
    end

    def reject
    end

    def to_s(io : IO) : Nil
      io << "#<Async::FiberPromise:#{self.object_id}> #{@state}"
    end

    def state
      @state
    end
  end
end
