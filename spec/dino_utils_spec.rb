require_relative 'spec_helper'
require 'dino_utils'

describe DinoUtils do
  it 'should load things' do
    Dino::S3.class
    Dino::Upsert.class
  end
end
