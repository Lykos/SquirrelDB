module Storage

  class PageAccessor

    PAGE_SIZE = 128

    def initialize( filename )
      @filename = filename
    end

    def get(page_no)
      File.open(@filename, File::RDONLY) do |f|
        f.seek(page_no * PAGE_SIZE, IO::SEEK_SET)
        f.read( PAGE_SIZE )
      end
    end

    def put(page_no, page)
      raise if page.length > PAGE_SIZE
      File.open( @filename, File::RDWR ) do |f|
        f.seek( page_no * PAGE_SIZE, IO::SEEK_SET )
        f.write( page.ljust( PAGE_SIZE, '\0' ) )
      end
    end

  end
  
end
