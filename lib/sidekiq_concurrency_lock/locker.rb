module SidekiqConcurrencyLock
  class Locker
    attr_reader :job_options

    def initialize(job_options)
      @job_options = job_options
    end

    def available?
      count == 0
    end

    def checkout
      increment_count
      begin
        yield
      ensure
        decrement_count
      end
    end

    def count
      $redis.get(lock_key).to_i
    end

    def increment_count
      $redis.incr(lock_key)
    end

    def decrement_count
      $redis.decr(lock_key)
    end

    def lock_key
      if job_options['concurrency_lock_key']
        "concurrency_lock:#{job_options['concurrency_lock_key']}"
      else
        "concurrency_lock:#{job_options['class']}"
      end
    end
  end
end
