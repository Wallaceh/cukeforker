module CukeForker
  class NormalisedEncodingFile
    COMMENT_OR_EMPTY_LINE_PATTERN = /^\s*#|^\s*$/ #:nodoc:
    ENCODING_PATTERN = /^\s*#\s*encoding\s*:\s*([^\s]+)/ #:nodoc:

    def self.read(path)
      new(path).read
    end

    def initialize(path)
      begin
        @file = File.new(path)
        set_encoding
      rescue Errno::EACCES => e
        raise FileNotFoundException.new(e, File.expand_path(path))
      rescue Errno::ENOENT => e
        raise FeatureFolderNotFoundException.new(e, path)
      end
    end

    def read
      @file.read.encode("UTF-8")
    end

    private

    def set_encoding
      @file.each do |line|
        if ENCODING_PATTERN =~ line
          @file.set_encoding $1
          break
        end
        break unless COMMENT_OR_EMPTY_LINE_PATTERN =~ line
      end
      @file.rewind
    end
  end
end