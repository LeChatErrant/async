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

  class FiberPromise(*T, R) < Promise
    include AsyncLogger

    @state = PromiseState::PENDING
    @is_waiting = false
    @channel = Channel(Nil).new
    @return_value : ReturnValue(R | Exception | Nil) = ReturnValue(R | Exception | Nil).new(nil)

    # Capturing any type of proc and its variadic argument in a GenericJob (equivalent of C++ std::bind)
    private def capture(callable, args)
      Job(typeof(callable), typeof(args)).new(callable, args)
    end

    def initialize(callable : Proc(*T, R), *args)
      puts "T =", T
      puts "R =", R
      job = capture(callable, args)
      spawn do
        tmp = job.call
        @return_value = ReturnValue(R | Exception | Nil).new(tmp)
        @state = PromiseState::RESOLVED
      rescue e
        @return_value = ReturnValue(R | Exception | Nil).new(e)
        @state = PromiseState::REJECTED
      ensure
        @channel.send(nil) if @is_waiting
      end
    end

    def wait
      if state != PromiseState::PENDING
        @return_value.try &.get
      else
        @is_waiting = true
        @channel.receive
        # The fact .try is needed is obscure. It seems to be a bug in the compiler ITSELF, as the object litterally disapear past this line, but still exists with a .try
        # Trying to .get without a .try results in a SEGFAULT in some cases (for example, in promise_example).
        # But in fact, return_value CAN'T be NULL
        @return_value.try &.get
      end
    end

    def get
      if state != PromiseState::PENDING
        @return_value.try &.get
      else
        @state
      end
    end

    def then(callable : T) forall T
      FiberPromise.new(->(this : self, callback : T) do
        value = await this
        if value.is_a? Tuple
          tmp = Function.new(*value)
          tmp.wrap callback
        else
          puts "not implemented yet!"
        end
      end, self, callable)
    end

    def catch(callable : T) forall T
      FiberPromise.new(->(this : self, callback : T) do
        value = await this
        #        tmp = Function.new(callback)
        # tmp = callable.partial value.as(Exception)
        #        tmp.call
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
