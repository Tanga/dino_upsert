module TN
  module Deadline
    ExpiredError = Class.new(StandardError)
    def self.start(seconds)
      Thread.current[:deadline_timer_start_time] = Time.now
      Thread.current[:deadline_timer_end_by] = Time.now + seconds
    end

    def self.time_left
      result = Thread.current[:deadline_timer_end_by] - Time.now
      fail ExpiredError.new if result <= 0
      result
    end
  end

  class Middleware
    def initialize(app, options={})
      timeout = options[:timeout]
      if defined?(Slowpoke)
        timeout ||= Slowpoke.timeout
      end
      @app = app
    end

    def call(env)
      TN::Deadline.start(timeout)
      @app.call(env)
    end
  end
end
