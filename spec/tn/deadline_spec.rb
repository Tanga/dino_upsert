require 'spec_helper'

describe TN::Deadline do
  it do
    seconds = 0.05
    described_class.start(seconds)
    t1 = described_class.time_left
    expect(t1).to be < seconds
    t2 = described_class.time_left
    expect(t2).to be < t1
    sleep 0.05
    expect { described_class.time_left }.to raise_error(TN::Deadline::ExpiredError)
  end
end
