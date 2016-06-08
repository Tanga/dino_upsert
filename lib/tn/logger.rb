require 'syslog/logger'
require 'json'

module TN
  # Logs json to syslog.
  # Automatically delegates stuff to the syslog logger.
  # Use like:
  #    TangaServices.logger.open('my_application_name')
  #    TangaServices.logger.info({message: "I'm interesting data"})
  #    TangaServices.logger.error({message: "i crashed"})
  class Logger < Syslog::Logger
    def self.application_name=(application_name)
      @application_name = application_name
    end

    def self.logger
      @logger || Syslog::Logger.new((@application_name || 'unknown'), Syslog::LOG_LOCAL7)
    end

    def self.debug(hash)
      log(:debug, hash)
    end

    def self.info(hash)
      log(:info, hash)
    end

    def self.write(message)
      log(:info, message: message)
    end
    class << self
      alias :<< :write
    end

    def self.warn(hash)
      log(:warn, hash)
    end

    def self.error(hash)
      log(:error, hash)
    end

    def self.fatal(hash)
      log(:fatal, hash)
    end

    def self.log(level, hash)
      unless hash.is_a?(Hash)
        hash = { object: hash }
      end

      fail ArgumentError, 'we just log hashes' unless hash.is_a?(Hash)
      data = { level: level, object: hash }
      logger.send(level, data.to_json)
    end

    def self.method_missing(method, *args, &block)
      logger.send(method, *args, &block)
    end
  end

  # Convience access to logger
  def self.logger
    Logger
  end
end
