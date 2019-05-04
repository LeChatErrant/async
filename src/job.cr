require "logger"
require "./async_logger.cr"

module Async
  private abstract class Job
    abstract def initialize
    abstract def call
  end

  private class GenericJob(T, K) < Job
    include AsyncLogger

    @logger = Logger.new(STDERR, level: default_severity_level)

    def initialize(@job : T, @args : K)
      @logger.debug "Created new job from callable #{T} with args #{K}"
    end

    def call
      @job.call *@args
    end
  end
end
