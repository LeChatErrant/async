require "logger"

# TODO: to wrap inside the main module
module AsyncLogger
  private macro default_severity_level
    {% if flag?(:release) %}
    Logger::ERROR
    {% else %}
    Logger::INFO
    {% end %}
  end

  # Change the level of severity beyond which the logger of your `FTPServer` will print logs
  #
  # NOTE: When building in release mode, the severity is by default at Logger::ERROR. Otherwise, it is set by default at Logger::INFO
  def verbose_level=(level : Logger::Severity)
    @logger.level = level
  end
end
