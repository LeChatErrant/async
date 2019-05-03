require "logger"
require "./AsynCrystalLogger.cr"


module AsynCrystal

  private abstract class Job
    abstract def initialize
    abstract def call
  end

  private class GenericJob(T, K) < Job

    include AsynCrystalLogger

    @logger = Logger.new(STDERR, level: default_severity_level)

    def initialize(@job : T, @args : K)
      @logger.debug "Created new job from callable #{T} with args #{K}"
    end

    def call
      @job.call *@args
    end
  end

end