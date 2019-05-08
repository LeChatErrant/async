require "../src/async.cr"

include Async

# Create a promise from a Proc
promise = FiberPromise.new(->(i : Int32) { puts i }, 12) # You can give arguments after the proc
# Notice that creating a Promise immediatly launch the wrapped Proc

# Await block the execution until the given Proc is finished
await FiberPromise.new(->do
  puts "time for a nap!"
  sleep 2.seconds
  puts "zzz..."
  sleep 2.seconds
  puts "I'm awake! :)"
end)
puts "I'm after await"

# Awaiting an already finished Promise don't have any effect
await promise

promise = FiberPromise.new(->do
  puts "Let's think about a number..."
  sleep 2.seconds
  Random.rand
end)

# Try displaying a promise : you'll get its state!
puts promise       # #<Async::FiberPromise:object_id> PENDING
puts promise.state # PENDING
# .get will return it's state too until resolved
puts promise.get # PENDING

# When a promise is resolved, you can access its returned value
promised_value = await promise
puts promised_value # Random number
puts promise.get    # Random number
puts promise.state  # RESOLVED
puts promise        # #<Async::FiberPromise:object_id> RESOLVED

# You can return inside a promise, and have different types of return value, or even multiple values at the same time!
# But prefer using `resolve` (it basically does the same thing, but indicates you are resolving a Promise)
conditionnal_proc = ->(toggle : Bool) do
  if toggle
    resolve "I received true! :)"
  end
  resolve false, "I received false... :("
end
puts await FiberPromise.new(conditionnal_proc, true)
puts await FiberPromise.new(conditionnal_proc, false)

# You can throw errors inside a promise. As for return, prefer using `reject`
# `reject` works the same way raise works, so you can pass a String or an Exception as parameter
promise = FiberPromise.new(->{
  reject "Oh, no!"
})

value = await promise
puts value       # Oh, no!
puts value.class # Exception

promise = FiberPromise.new(->{
  reject Exception.new("Oh, no!")
})

value = await promise
puts value       # Oh, no!
puts value.class # Exception


# CALLBACKS ARE STILL IN DEVELOPMENT AND NOT READY NOW


# You can pass callbacks to you promise (Proc that will be executed AFTER your promise)
# Success callback is added with .then and failure callback is added with .catch

# A success callaback
promise = FiberPromise.new(->{
  puts "Time for a nap..."
  sleep 2.seconds
})
promise.then(->{ puts "I had a good night! :)" })

puts "I wonder if he's still sleeping..."
sleep 3

# A success callaback
promise = FiberPromise.new(->{
  puts "Time to work..."
  sleep 2.seconds
  reject "Coffee" #TODO : test without reject! :/
})
promise.catch(->(e : Exception) { puts "I should go drink #{e.message}!" })

puts "I wonder if he's still working..."
sleep 4.seconds

# # Callbacks can be chained, like this

# FiberPromise.new(->{
#   puts "hello"
# }).then(->{
#   "a success!"
# }).then(->{
#   "again a success?"
# }).catch(->{
#   "i'm a failure..."
# })

# # Notice that if an error is thrown, all the .then blocks will be skipped until a .catch block is found

# FiberPromise.new(->{
#   reject "Oh no!"
# }).then(->{
#   "I won't be called if an error is thrown..."
# }).catch(->{
#   "Gotcha!"
# })

# # You can add callbacks too with .finally
# # Finally callbacks will be called in ANY cases, either if the Promise is REJECTED or RESOLVED

# FiberPromise.new(->{
#   puts "hello"
# }).then(->{
#   "RESOLVED"
# }).catch(->{
#   "REJECTED"
# }).finally(->{
#   "ANY CASE"
# })