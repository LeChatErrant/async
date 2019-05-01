def test(x, y)
  puts x
  puts y
end


class Test(*T)

#  @jobs = Deque(Proc(*(typeof (T), Nil)).new
@jobs = Dequeue(Tuple(*T))

  def initialize
    puts typeof(T)
  end

  def add_job()
    puts d
  end
end

#test = Test(Int32).new
test = Test(Int32, String).new
#test = Test(Nil).new

x = {1, 2}

puts typeof(Int32)

y = {Int32, String}
test *x
test *y