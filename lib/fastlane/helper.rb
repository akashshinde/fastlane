require 'logger'

class String
  def classify
    split('_').collect!(&:capitalize).join
  end
end

module Fastlane
  module Helper
    # Logging happens using this method
    def self.log
      if test?
        @log ||= Logger.new(nil) # don't show any logs when running tests
      else
        @log ||= Logger.new(STDOUT)
      end

      @log.formatter = proc do |severity, datetime, _progname, msg|
        string = "#{severity} [#{datetime.strftime('%Y-%m-%d %H:%M:%S.%2N')}]: "
        second = "#{msg}\n"

        if severity == 'DEBUG'
          string = string.magenta
        elsif severity == 'INFO'
          string = string.white
        elsif severity == 'WARN'
          string = string.yellow
        elsif severity == 'ERROR'
          string = string.red
        elsif severity == 'FATAL'
          string = string.red.bold
        end

        [string, second].join('')
      end

      @log
    end

    # @return true if the currently running program is a unit test
    def self.test?
      defined?SpecHelper
    end

    # @return the full path to the Xcode developer tools of the currently
    #  running system
    def self.xcode_path
      return '' if self.test? && !OS.mac?
      `xcode-select -p`.gsub("\n", '') + '/'
    end

    def self.gem_path
      if !Helper.test? && Gem::Specification.find_all_by_name('fastlane').any?
        return Gem::Specification.find_by_name('fastlane').gem_dir
      else
        return './'
      end
    end
  end
end
