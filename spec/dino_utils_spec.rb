require_relative 'spec_helper'

class Foo < ActiveRecord::Base
end

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

  it 'can upsert hstore' do
    Foo.upsert(t: 'joe', h: { x: '1' })
    Foo.upsert(t: 'joe', h: { x: '1' })
    Foo.upsert(t: 'peter', h: { x: '1' })
    Foo.upsert(t: 'peter', h: { x: '2' })
    foos = Foo.order(:id).all
    expect(foos[0].t).to be == 'joe'
    expect(foos[0].h).to be == { 'x' => '1' }
    expect(foos[1].t).to be == 'peter'
    expect(foos[1].h).to be == { 'x' => '1' }
    expect(foos[2].t).to be == 'peter'
    expect(foos[2].h).to be == { 'x' => '2' }
    expect(Foo.count).to be == 3
  end
end
