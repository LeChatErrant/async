require "./promise.cr"
require "../job"
require "../logger"

module Async
  class FiberPromise < Promise
    include AsyncLogger

    getter state = PromiseState::PENDING
    @is_waiting = false
    @channel = Channel(Nil).new

    # Capturing any type of proc and its variadic argument in a GenericJob (equivalent of C++ std::bind)
    private def capture(callable, args)
      Job(typeof(callable), typeof(args)).new(callable, args)
    end

    def initialize(callable, *args)
      job = capture(callable, args)
      spawn do
        @return_value = job.call
        @state = PromiseState::RESOLVED
        @channel.send(nil) if @is_waiting
      end
    end

    def wait
      @is_waiting = true
      @channel.receive
      @return_value
    end

    def get
      if state == PromiseState::RESOLVED
        @return_value
      else
        @state
      end
    end

    def then
    end

    def catch
    end

    def resolve
    end

    def reject
    end

    def to_s
    end
  end
end
