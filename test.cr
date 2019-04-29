def test_it(a, b, c)
  puts a
  puts b
  puts c
end

test_it 1, 2, 3
elems = {1, 2, 3}
test_it *elems

class Job(T)
  getter @job : T

  def initialize(&job)
    @job = job
  end

  def call(args)
    @job.call *args
  end
end

job = Job.new { |i| puts i }
job.call [i]