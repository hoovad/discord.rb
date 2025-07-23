# frozen_string_literal: true

# Logger2 (class Logger already exists in Ruby)
# Logging handler with some cool styling
class Logger2
  def initialize(verbosity_level)
    @verbosity_level = verbosity_level
  end

  def error(message)
    return unless @verbosity_level >= 1

    puts("\033[1;38;2;255;255;255;48;2;192;57;43m | ERROR          \033[0m\033[38;2;255;255;255;48;2;44;62;80m" \
         " #{Time.now.strftime('%Y-%m-%d %H:%M:%S')} \033[0m\033[1;38;2;255;255;255;48;2;192;57;43m  \033[0m " \
         "\e[38;2;192;57;43m#{message}\e[0m")
  end

  def debug(message)
    return unless @verbosity_level == 4

    puts("\033[1;38;2;255;255;255;48;2;155;89;182m | DEBUG          \033[0m\033[38;2;255;255;255;48;2;44;62;80m" \
         " #{Time.now.strftime('%Y-%m-%d %H:%M:%S')} \033[0m\033[1;38;2;255;255;255;48;2;155;89;182m  \033[0m " \
         "\e[38;2;155;89;182m#{message}\e[0m")
  end

  def warn(message)
    return unless @verbosity_level >= 2

    puts("\033[1;38;2;255;255;255;48;2;243;156;18m | WARNING        \033[0m\033[38;2;255;255;255;48;2;44;62;80m" \
         " #{Time.now.strftime('%Y-%m-%d %H:%M:%S')} \033[0m\033[1;38;2;255;255;255;48;2;243;156;18m  \033[0m " \
         "\e[38;2;243;156;18m#{message}\e[0m")
  end

  def info(message)
    return unless @verbosity_level >= 3

    puts("\033[1;38;2;255;255;255;48;2;76;175;80m | INFORMATION    \033[0m\033[38;2;255;255;255;48;2;44;62;80m" \
         " #{Time.now.strftime('%Y-%m-%d %H:%M:%S')} \033[0m\033[1;38;2;255;255;255;48;2;76;175;80m  \033[0m " \
         "\e[38;2;76;175;80m#{message}\e[0m")
  end

  def self.s_error(message)
    puts("\033[1;38;2;255;255;255;48;2;192;57;43m | ERROR          \033[0m\033[38;2;255;255;255;48;2;44;62;80m" \
           " #{Time.now.strftime('%Y-%m-%d %H:%M:%S')} \033[0m\033[1;38;2;255;255;255;48;2;192;57;43m  \033[0m " \
           "\e[38;2;192;57;43m#{message}\e[0m")
  end

  def self.s_debug(message)
    puts("\033[1;38;2;255;255;255;48;2;155;89;182m | DEBUG          \033[0m\033[38;2;255;255;255;48;2;44;62;80m" \
           " #{Time.now.strftime('%Y-%m-%d %H:%M:%S')} \033[0m\033[1;38;2;255;255;255;48;2;155;89;182m  \033[0m " \
           "\e[38;2;155;89;182m#{message}\e[0m")
  end

  def self.s_warn(message)
    puts("\033[1;38;2;255;255;255;48;2;243;156;18m | WARNING        \033[0m\033[38;2;255;255;255;48;2;44;62;80m" \
           " #{Time.now.strftime('%Y-%m-%d %H:%M:%S')} \033[0m\033[1;38;2;255;255;255;48;2;243;156;18m  \033[0m " \
           "\e[38;2;243;156;18m#{message}\e[0m")
  end

  def self.s_info(message)
    puts("\033[1;38;2;255;255;255;48;2;76;175;80m | INFORMATION    \033[0m\033[38;2;255;255;255;48;2;44;62;80m" \
           " #{Time.now.strftime('%Y-%m-%d %H:%M:%S')} \033[0m\033[1;38;2;255;255;255;48;2;76;175;80m  \033[0m " \
           "\e[38;2;76;175;80m#{message}\e[0m")
  end
end
