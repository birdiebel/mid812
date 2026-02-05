if Rails.env.development?
  module Kernel
    alias_method :original_puts, :puts

    def puts(*args)
      $stdout.print "\e[32m" # Green color
      original_puts(*args)
      $stdout.print "\e[0m"  # Reset color
    end
  end
end
