module TN
  class TempFile
    def initialize(content: nil, file: nil, name: 'tanga')
      extension = File.extname(name)
      file_name = SecureRandom.hex
      @file = file || ::Tempfile.new([file_name, extension])
      @file.binmode
      if content
        @file.write(content) if content
        @file.close
      end

      if block_given?
        yield(self)
        done
      end
    end

    def method_missing(method, *args, &block)
      @file.send(method, *args, &block)
    end

    def path
      File.absolute_path(@file.path)
    end

    def done
      @file.close
      @file.unlink
    end
  end
end
