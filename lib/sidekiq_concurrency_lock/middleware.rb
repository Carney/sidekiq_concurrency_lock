module SidekiqConcurrencyLock
  class Middleware
    def call(worker, msg, queue)
      if msg['concurrency_lock']
        locker = Locker.new(msg)
        if locker.available?
          locker.checkout do
            yield
          end
        else
          worker.class.perform_in(60 + rand(20), *msg['args'])
        end
      else
        yield
      end
    end
  end
end
