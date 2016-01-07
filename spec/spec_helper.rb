$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'dino_utils'
require 'rspec-given'

RSpec.configure do |c|
  c.before :suite do
    ENV['DATABASE_URL'] ||= "postgres://localhost/dino_utils_test"
    ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])
    ActiveRecord::Base.connection.execute <<-SQL
    create extension if not exists hstore;
    drop table if exists foos;
    create table foos(id serial primary key, t text, h hstore, j json);
    SQL
  end

  c.before do
    ActiveRecord::Base.connection.execute "truncate foos"
  end

  c.after :suite do
  end
end
