require "./generic_job.cr"

module Async
  private class Job(T, K) < GenericJob
    def initialize(@callable : T, @args : K)
    end

    def call
      @callable.call *@args
    end
  end
end
