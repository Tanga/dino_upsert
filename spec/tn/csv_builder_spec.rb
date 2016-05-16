require 'spec_helper'

describe TN::CSVBuilder do
  class ProductExport
    include TN::CSVBuilder
    csv_header :id,   name: 'ID'
    csv_header :name, name: 'Name'
    csv_header :price

    def csv_data
      10.times do |i|
        yield(id: "x" * 50,
              price: 1.99,
              name: i + 2)
      end
    end
  end

  it 'can generate a CSV file' do
    result = ""
    ProductExport.new.csv(result)
    csv_data = CSV.parse(result, headers: true)
    expect(csv_data.size).to be == 10
    expect(csv_data[0].to_hash).to be == {"ID" => "x" * 50, "Name" => "2", "price" => "1.99"}
  end

  it "can write to a tempfile" do
    file = ProductExport.new.generate_csv_tempfile
    csv_data = CSV.parse(IO.read(file.path), headers: true)
    expect(csv_data.size).to be == 10
    expect(csv_data[0].to_hash).to be == {"ID" => "x" * 50, "Name" => "2", "price" => "1.99"}
  end

  context "flushing after each row" do
    it 'can flush after each row' do
      expect_any_instance_of(CSV).to receive(:flush).exactly(10).times.and_call_original
      file = ProductExport.new.generate_csv_tempfile(flush_after_each_row: true)
      csv_data = CSV.parse(IO.read(file.path), headers: true)
      expect(csv_data.size).to be == 10
      expect(csv_data[0].to_hash).to be == {"ID" => "x" * 50, "Name" => "2", "price" => "1.99"}
    end

    it "doesn't flush by default" do
      expect_any_instance_of(CSV).to_not receive(:flush)
      file = ProductExport.new.generate_csv_tempfile
      csv_data = CSV.parse(IO.read(file.path), headers: true)
      expect(csv_data.size).to be == 10
      expect(csv_data[0].to_hash).to be == {"ID" => "x" * 50, "Name" => "2", "price" => "1.99"}
    end
  end

  describe "with an initializer" do
    class WithInit
      include TN::CSVBuilder
      csv_header :id
      def initialize(data)
        @data = data
      end
      def csv_data
        @data.each { |d| yield d }
      end
    end
    it 'should yield the init data' do
      result = ""
      WithInit.new([{id: 1}]).csv(result)
      expect(result).to be == "id\n1\n"
    end
  end
end
