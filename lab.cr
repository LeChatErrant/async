def test(x, y)
  puts x
  puts y
  return "hello"
end


abstract class IJob
  abstract def initialize
  abstract def call
end

class Job(T, K) < IJob

  def initialize(@job : T, @args : K)
    puts {{ T.superclass }}
    puts {{ T.ancestors }}
    puts T
    puts K
  end

  def call()
    @job.call *@args
  end
end

class FiberPool
  @jobs = Deque(IJob).new

  def initialize
  end

  def add_job(func, *args)
    job = Job(typeof(func), typeof(args)).new(func, args)
    @jobs.push(job)
    job.call()
  end
end


# class FiberPool
#   @jobs = Deque(IJob).new

#   def initialize
#   end

#   def add_job(*args)
#     job = Job(typeof(args[0])).new(args[0])
#     @jobs.push(job)
#   end
# end

proc = ->test(Int32, Int32)
fiberpool = FiberPool.new
fiberpool.add_job(proc, 1, 2)
fiberpool.add_job(->(i : Int32){
  puts i
  return "dab"
}, 7)
fiberpool.add_job(->{puts "hello"})
# puts typeof(proc)
# job = Job(typeof(proc)).new(proc)
#job = Job(Int32, Int32).new(proc)
#job.call(1, 2)

# #test = Test(Int32).new
# test = Test(Int32, String).new
# #test = Test(Nil).new

# x = {1, 2}

# puts typeof(Int32)

# y = {Int32, String}
# test *x
# test *y