require 'digest'

class TN::AdvisoryLock
  def initialize(key, wait: false)
    key = self.class.string_to_int(key) unless key.is_a?(Integer)
    @key  = key
    @wait = wait
  end

  # Convert a string to a int that's needed for the advisory lock.
  def self.string_to_int(string)
    Digest::SHA1.hexdigest(string)[0..10].to_i(36)
  end

  def self.with_lock(key, wait: false)
    result = nil
    new(key, wait: wait).exclusive do
      result = yield
    end
    result
  end

  def exclusive
    if acquired?
      begin
        yield
      ensure
        release!
      end
    else
      return false
    end
    true
  end

private

  def acquired?
    TN.execute_sql("select #{sql_function}(#{@key})") != "f"
  end

  def sql_function
    if @wait
      "pg_advisory_lock"
    else
      "pg_try_advisory_lock"
    end
  end

  def release!
    TN.execute_sql("select pg_advisory_unlock(#{@key})")
  end
end
