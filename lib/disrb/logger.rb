# frozen_string_literal: true

# Logging handler with some cool styling (called Logger2 because Logger is a built-in Ruby class)
#
# When you create an instance of this class, you need to set the verbosity level, and when you run the instance methods,
# it will follow the set verbosity level. Example: you create a Logger2 instance with verbosity level 3 (warning),
# only the methods "fatal_error", "error" and "warn" will print to the console. The class methods (start with s_)
# will always print to the console.
class Logger2
  # Creates a new Logger2 instance.
  #
  # verbosity_level can be set to:
  # - 0: No logging.
  # - 1: Fatal errors only.
  # - 2: Fatal errors and errors.
  # - 3: All of the above and warnings.
  # - 4: All of the above and information messages.
  # - 5: All of the above and debug messages.
  # @param verbosity_level [Integer] The verbosity level for the logger to follow.
  # @return [Logger2] Logger2 instance.
  def initialize(verbosity_level)
    @verbosity_level = verbosity_level
  end

  def base(acolor1, acolor2, acolor3, name, message)
    name = name.ljust(14, ' ')
    acolors = [acolor1, acolor2, acolor3].join(';')
    "\033[1;38;2;255;255;255;48;2;#{acolors}m | #{name} \033[0m\033[38;2;255;255;255;48;2;44;62;80m" \
      " #{Time.now.strftime('%Y-%m-%d %H:%M:%S')} \033[0m\033[1;38;2;255;255;255;48;2;#{acolors}m  \033[0m " \
      "\e[38;2;#{acolors}m#{message}\e[0m"
  end

  # Logs a fatal error to the console if the verbosity level is set to 1 or higher.
  # @param message [String] The message to log.
  # @return [nil]
  def fatal_error(message)
    return unless @verbosity_level >= 1

    puts(base(192, 57, 43, 'FATAL ERROR', message))
  end

  # Logs an error to the console if the verbosity level is set to 2 or higher.
  # @param message [String] The message to log.
  # @return [nil]
  def error(message)
    return unless @verbosity_level >= 2

    puts(base(243, 156, 18, 'ERROR', message))
  end

  # Logs a debug message to the console if the verbosity level is set to 5.
  # @param message [String] The message to log.
  # @return [nil]
  def debug(message)
    return unless @verbosity_level == 5

    puts(base(155, 89, 182, 'DEBUG', message))
  end

  # Logs a warning to the console if the verbosity level is set to 3 or higher.
  # @param message [String] The message to log.
  # @return [nil]
  def warn(message)
    return unless @verbosity_level >= 3

    puts(base(241, 196, 15, 'WARNING', message))
  end

  # Logs an info message to the console if the verbosity level is set to 4 or higher.
  # @param message [String] The message to log.
  # @return [nil]
  def info(message)
    return unless @verbosity_level >= 4

    puts(base(76, 175, 80, 'INFORMATION', message))
  end

  # Logs a fatal error to the console
  # @param message [String] The message to log.
  # @return [nil]
  def self.s_fatal_error(message)
    puts(base(192, 57, 43, 'FATAL ERROR', message))
  end

  # Logs an error to the console
  # @param message [String] The message to log.
  # @return [nil]
  def self.s_error(message)
    puts(base(243, 156, 18, 'ERROR', message))
  end

  # Logs a debug message to the console
  # @param message [String] The message to log.
  # @return [nil]
  def self.s_debug(message)
    puts(base(155, 89, 182, 'DEBUG', message))
  end

  # Logs a warning to the console
  # @param message [String] The message to log.
  # @return [nil]
  def self.s_warn(message)
    puts(base(241, 196, 15, 'WARNING', message))
  end

  # Logs an info message to the console
  # @param message [String] The message to log.
  # @return [nil]
  def self.s_info(message)
    puts(base(76, 175, 80, 'INFORMATION', message))
  end
end
