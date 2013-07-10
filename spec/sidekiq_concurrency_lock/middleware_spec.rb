require 'spec_helper'

describe SidekiqConcurrencyLock::Middleware do
  class MockWorker
    def self.perform_in(*)
    end
  end

  let(:worker) { MockWorker.new }

  before(:each) do
    $redis.keys("concurrency_lock:*").each do |key|
      $redis.del(key)
    end
  end

  context "concurrency lock enabled" do
    it "only allows one job to be run" do
      count = 0

      subject.call(worker, {'concurrency_lock' => true, 'class' => 'Foo'}, nil) do
        count += 1
        subject.call(worker, {'concurrency_lock' => true, 'class' => 'Foo'}, nil) do
          count += 1
        end
      end

      count.should == 1
    end

    it "releases the lock after each job" do
      count = 0

      subject.call(worker, {'concurrency_lock' => true, 'class' => 'Foo'}, nil) do
        count += 1
      end

      subject.call(worker, {'concurrency_lock' => true, 'class' => 'Foo'}, nil) do
        count += 1
      end

      count.should == 2
    end

    it "enqueues the job for retry if locked" do
      subject.stub(:rand).and_return(5)
      subject.should_receive(:rand).with(20)

      MockWorker.should_receive(:perform_in).
        with(65, 'wat', 'cats')

      subject.call(worker, {'concurrency_lock' => true, 'class' => 'Foo'}, nil) do
        subject.call(worker, {'concurrency_lock' => true, 'class' => 'Foo', 'args' => ['wat', 'cats']}, nil) do
        end
      end
    end

    context "different classes of jobs" do
      it "allows the two different jobs to be run simultaneously" do
        count = 0
        subject.call(worker, {'concurrency_lock' => true, 'class' => 'Foo'}, nil) do
          count += 1
          subject.call(worker, {'concurrency_lock' => true, 'class' => 'Bar'}, nil) do
            count += 1
          end
        end
        count.should == 2
      end

      context "concurrency lock key set" do
        it "only allows one job to be run even though they have different classes" do
          count = 0

          subject.call(worker, {'concurrency_lock' => true,
                             'class' => 'Foo',
                             'concurrency_lock_key' => 'wat'}, nil) do
            count += 1
            subject.call(worker, {'concurrency_lock' => true,
                               'class' => 'Bar',
                               'concurrency_lock_key' => 'wat'}, nil) do
              count += 1
            end
          end

          count.should == 1
        end
      end
    end
  end

  context "concurrency lock disabled" do
    it "allows two jobs to be run simultaneously" do
      count = 0
      subject.call(worker, {'class' => 'Foo'}, nil) do
        count += 1
        subject.call(worker, {'class' => 'Foo'}, nil) do
          count += 1
        end
      end
      count.should == 2
    end
  end
end
