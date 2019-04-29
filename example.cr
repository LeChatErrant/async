require "logger"
require "./src/FiberPool.cr"

fiber_pool = FiberPool::FiberPool(Tuple(Int32, String)).new(1)
fiber_pool.verbose_level = Logger::DEBUG

10.times do
  fiber_pool.add_job(1, "hello") do |args|
    args[0].times { puts args[1] }
    sleep 3
  end
end

sleep
