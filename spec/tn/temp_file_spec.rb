require 'spec_helper'

describe TN::TempFile do
  it 'can create from content' do
    file = described_class.new(content: 'joe', name: 'helloo')
    expect(File.exist?(file.path)).to be true
    expect(File.read(file.path)).to be == 'joe'
  end

  it 'can set the file extension' do
    filename = 'https://www.tanga.com/wutwut/hello.jpg'
    file = described_class.new(content: 'joe', name: filename)
    expect(file.path).to match(/\.jpg$/)
  end

  it 'can have other programs write to the path' do
    file = described_class.new
    `cat #{__FILE__} > #{file.path}`
    expect(File.read(file.path).lines.first).to be == "require 'spec_helper'\n"
  end

  it 'can create from tempfile' do
    begin
      file = Tempfile.new('foo')
      file << 'joe'
      described_class.new(file: file)
      file.close
      expect(File.read(file.path)).to be == 'joe'
    ensure
      file.close!
    end
  end
end
