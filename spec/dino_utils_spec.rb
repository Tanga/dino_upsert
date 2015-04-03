require_relative 'spec_helper'

describe DinoUtils do
  it 'should call transaction' do
    klass = double
    expect(klass).to receive(:transaction)
    Dino::Upsert.upsert(klass, {})
  end

  it 'retry properly' do
    klass = double
    expect(klass).to receive(:transaction).exactly(11).times do
      raise ActiveRecord::RecordNotUnique, 'foo'
    end
    expect { Dino::Upsert.upsert(klass, {}) }.to raise_error(ActiveRecord::RecordNotUnique)
  end
end
