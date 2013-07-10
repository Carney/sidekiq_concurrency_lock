# SidekiqConcurrencyLock

A Sidekiq middleware for limiting the concurrency of jobs on a per-class basis.

Useful if you have a job that you really don't want to run more than one of at
a time.

Note: this does not reduce the overall concurrency of sidekiq, and you'll still
be dealing with threads of your other jobs.

## Installation

Add this line to your application's Gemfile:

    gem 'sidekiq_concurrency_lock'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sidekiq_concurrency_lock

## Usage

In your sidekiq configuration (in Rails: `config/initializers/sidekiq.rb`),
add it as a `server_middleware`:

    Sidekiq.configure_server do |config|
      config.server_middleware do |chain|
        chain.add SidekiqConcurrencyLock
      end
    end

In your job, enable the concurrency lock:

    class MyJob
      include Sidekiq::Worker
      sidekiq_options concurrency_lock: true

      def perform
        # do stuff without worry about concurrency for this job
      end
    end

You can optionally specify a lock key to share the same lock across classes:

    class JobA
      include Sidekiq::Worker
      sidekiq_options concurrency_lock: true,
                      concurrency_lock_key: 'there-can-only-be-one'

      def perform
        # do stuff without worry about concurrency for JobA or JobB
      end
    end

    class JobB
      include Sidekiq::Worker
      sidekiq_options concurrency_lock: true,
                      concurrency_lock_key: 'there-can-only-be-one'

      def perform
        # do stuff without worry about concurrency for JobA or JobB
      end
    end

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
