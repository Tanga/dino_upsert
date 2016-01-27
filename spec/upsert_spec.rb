require_relative 'spec_helper'

describe Dino::Upsert do
  it 'should upsert' do
    expect(Foo.upsert(t: 'joe').t).to be == 'joe'
  end

  it 'should not insert duplicates' do
    expect do
      Foo.upsert({t: 'joe'})
      Foo.upsert({t: 'chris'})
      Foo.upsert({t: 'joe'}, t: 'jim')
    end.to change { Foo.count }.by(2)
  end

  it 'should be able to insert/update attributes' do
    Foo.upsert({t: 'joe'})
    Foo.upsert({t: 'joe'}, t: 'chris')
    expect(Foo.last.t).to be == 'chris'
  end

  it 'should be able to modify object before saving or updating' do
    object = Foo.upsert(t: 'joe') do |foo|
      foo.j = {blah: true}
    end
    expect(object.reload.j).to be == { "blah" => true }

    object = Foo.upsert(t: 'joe') do |foo|
      foo.j = {blah: false}
    end
    expect(object.reload.j).to be == { "blah" => false }
  end
end
