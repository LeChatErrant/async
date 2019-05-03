require "logger"
require "./AsynCrystal.cr"

module AsynCrystal

  abstract class Job
    abstract def initialize
    abstract def call
  end

  class Job(T, K) < Job

    @logger = Logger.new(STDERR, level: default_severity_level)

    def initialize(@job : T, @args : K)
      @logger.debug "Created new job from callable #{T} with args #{K}"
    end

    def call()
      @job.call *@args
    end
  end

end