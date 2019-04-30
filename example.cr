require "logger"
require "./src/FiberPool.cr"

fiber_pool = FiberPool::FiberPool(Tuple(Int32, String)).new(1)
fiber_pool.verbose_level = Logger::DEBUG

5.times do
  fiber_pool.add_job(1, "hello") do |args|
    args[0].times { puts args[1] }
    sleep 2.seconds
  end
  puts "Nb of jobs queued : #{fiber_pool.size}"
end

10.times { puts "dab" }

sleep 5

3.times do
  fiber_pool.add_job(1, "hello") do |args|
    puts "STARFOULLAAAAAAH"
    sleep 1.seconds
  end
  puts "Nb of jobs queued : #{fiber_pool.size}"
end

sleep