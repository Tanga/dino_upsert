require 'active_record'
require 'pg'

module Dino
  # Provides a simple way to do an create or update of an ActiveRecord object.
  module Upsert
    extend ActiveSupport::Concern
    # User.upsert
    module ClassMethods
      def upsert(*args)
        Dino::Upsert.upsert(self, *args)
      end
    end

    # klass: The ActiveRecord class we are upserting against.
    # conditions: what should match the upsert
    # options: what we are updating/inserting
    # If provided, the block gets the object before it's saved, in case
    #   there's special init options necessary for it.
    # rubocop:disable MethodLength
    def self.upsert(klass, data, options = {}, &block)
      retry_count = 0
      data_copy = {}
      data.each do |k, v|
        if v.kind_of?(Hash)
          v = klass.column_for_attribute(k).type_cast_for_database(v)
        end
        data_copy[k] = v
      end
      begin
        klass.transaction(requires_new: true) do
          klass.where(data_copy).first_or_initialize(&block).tap { |t| t.update!(options) }
        end
      rescue PG::UniqueViolation, ActiveRecord::RecordNotUnique
        # If there's a unique violation, retry this. But only a certain amount
        # of times or we'll get into an infinite loop if something's messed up.
        # (like an incorrect unique index or something)
        if retry_count < 10
          retry_count += 1
          retry
        else
          raise
        end
      end
    end
  end
end

ActiveRecord::Base.send(:include, Dino::Upsert)
