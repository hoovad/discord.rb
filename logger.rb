# frozen_string_literal: true

# Logger
# Logging handler with some cool styling
class Logger
  def self.error(message)
    warn("\033[1;38;2;255;255;255;48;2;192;57;43m | ERROR          \033[0m\033[38;2;255;255;255;48;2;44;62;80m" \
         " #{Time.now.strftime('%Y-%m-%d %H:%M:%S')} \033[0m\033[1;38;2;255;255;255;48;2;192;57;43m  \033[0m " \
         "\e[38;2;192;57;43m#{message}\e[0m")
  end

  def self.debug(message)
    puts("\033[1;38;2;255;255;255;48;2;155;89;182m | DEBUG          \033[0m\033[38;2;255;255;255;48;2;44;62;80m" \
         " #{Time.now.strftime('%Y-%m-%d %H:%M:%S')} \033[0m\033[1;38;2;255;255;255;48;2;155;89;182m  \033[0m " \
         "\e[38;2;155;89;182m#{message}\e[0m")
  end

  def self.warn(message)
    puts("\033[1;38;2;255;255;255;48;2;243;156;18m | WARNING        \033[0m\033[38;2;255;255;255;48;2;44;62;80m" \
         " #{Time.now.strftime('%Y-%m-%d %H:%M:%S')} \033[0m\033[1;38;2;255;255;255;48;2;243;156;18m  \033[0m " \
         "\e[38;2;243;156;18m#{message}\e[0m")
  end

  def self.info(message)
    puts("\033[1;38;2;255;255;255;48;2;76;175;80m | INFORMATION    \033[0m\033[38;2;255;255;255;48;2;44;62;80m" \
         " #{Time.now.strftime('%Y-%m-%d %H:%M:%S')} \033[0m\033[1;38;2;255;255;255;48;2;76;175;80m  \033[0m " \
         "\e[38;2;76;175;80m#{message}\e[0m")
  end
end
