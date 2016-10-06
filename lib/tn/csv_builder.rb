require 'csv'

module TN::CSVBuilder
  module ClassMethods
    def csv_header(attribute, name: attribute)
      @csv_headers ||= {}
      @csv_headers[attribute] = name
    end

    attr_reader :csv_headers
  end

  module InstanceMethods
    def csv(io, flush_after_each_row: false)
      csv_header_row ||= CSV::Row.new(csv_headers.keys, csv_headers.values, true)
      csv = CSV.new(io)
      csv << csv_header_row
      csv_data do |row|
        row_data = []
        csv_headers.each do |key, _|
          row_data << row[key]
        end
        row.each do |key, _|
          fail "#{key} not a valid csv header!" unless csv_headers.key?(key)
        end
        csv << CSV::Row.new(csv_headers, row_data)
        csv.flush if flush_after_each_row
      end
      csv
    end

    def file(flush_after_each_row: false)
      file = TN::TempFile.new
      csv(file, flush_after_each_row: flush_after_each_row)
      file.close
      yield(file) if block_given?
      file
    end
    alias generate_csv_tempfile file

    def csv_headers
      self.class.csv_headers
    end
  end

  def self.included(klass)
    klass.extend(ClassMethods)
    klass.send(:include, InstanceMethods)
  end
end
