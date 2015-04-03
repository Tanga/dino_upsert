require 'aws-sdk'

module Dino::S3
  def self.bucket_name
    Dino.get_setting('aws.s3.assets.bucket_name')
  end

  def self.url(filename)
    @_hostname ||= Dino.get_setting('images.source_url')
    "#{@_hostname}#{filename}"
  end

  def self.upload(file_or_string, destination=SecureRandom.hex)
    path =
      if file_or_string.respond_to?(:path)
        file_or_string.path
      else
        temp = Tempfile.new('s3_file')
        temp.binmode # switch to binary
        temp << file_or_string
        temp.close
        temp.path
      end

    pathname = Pathname.new(path)

    return if defined?(Rails) && Rails.env.test? # Don't bother uploading in tests.
    new_file = s3.buckets[bucket_name].objects[destination]
    begin
      new_file.write(pathname, acl: :public_read)
      Dino::Database.sequel do |db|
        db[:s3_files].insert(filename: destination, size: File.size(path))
      end
    rescue
      puts file_or_string.inspect
      puts $!
      puts $!.backtrace
      raise
    end
    Dino::S3.url(destination)
  end

  # private

  def self.s3
    options = {
      access_key_id:     Dino::Settings.get_setting('aws.s3.assets.access_key_id'),
      secret_access_key: Dino::Settings.get_setting('aws.s3.assets.secret_access_key')
    }

    # Used only in development with the fakes3 service
    if (endpoint = Dino::Settings.get_setting('aws.s3.assets.endpoint', allow_empty: true))
      options[:s3_endpoint] = endpoint
      options[:s3_force_path_style] = true
    end

    AWS::S3.new(options)
  end
end
