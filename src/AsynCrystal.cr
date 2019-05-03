require "./FiberPool.cr"

module AsyncCrystal
  VERSION = "0.2.0"

  macro default_severity_level
    {% if flag?(:release) %}
    Logger::ERROR
    {% else %}
    Logger::INFO
    {% end %}
  end
end