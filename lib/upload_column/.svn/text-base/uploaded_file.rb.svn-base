module UploadColumn
  
  class UploadedFile < SanitizedFile
    
    # Determines if the requested file actually exists in the filesystem or not.
    def exists?
      File.exists? File.join(self.dir, self.filename)
    end

    # Returns a hash of only the versions that exist as real files
    def valid_versions
      valids = versions.reject{ |v,f| !f.exists? }
      valids.delete(:original) if self.pdf.filename == self.original.filename
      valids
    end
    
    # Returns the public_filename option that was passed during initialization, or filename if blank. This filename is
    # typically used when sending the file to the user's browser, allowing us to store the file using a fairly benign filename
    # but include more useful information in the filename sent to the user, such as a name that might change from time to time.
    def public_filename
      self.options[:public_filename].nil? ? self.filename : parse_dir_options(:public_filename)
    end

    # Returns the file's size
    def size
      # return @file.size if @file.respond_to?(:size)
      File.size(self.path) rescue 0
    end
    
    # Returns the content_type of the file as determined through the MIME::Types library or through a *nix exec.
    def content_type
      %x(file -bi "#{self.path}").chomp.scan(/^[a-z0-9\-_]+\/[a-z0-9\-_]+/).first
    end    

    # Hack to get the right file extension!
    def ext
      b,e = split_extension(filename)
      e
    end

    # def move_to_directory(dir)
    #   p = File.join(dir, self.filename)
    #   puts "Moving #{p}"
    #   if copy_file(p)
    #     @path = p
    #   end
    # end
    # 
    
    private
    
    # Override copy_to_version so that you can disable creating clones of the file for different versions by passing :copy_to_versions 
    # as false. This allows UploadedFile to still think it has versions but not allow them to exist in the filesystem. Since EXPo does
    # much of its file manipulations using asynchronous processes (e.g., converting to PDF with OpenOffice), these versions basically
    # tell us which versions we are planning or need to create. Using +exists?+, we can see how far we come. This also allows us to have
    # files without certain versions -- for example, if something cannot be converted to PDF for some reason.
    def copy_to_version(version)
#      backup_existing_file #always backup the current file and move it out of the way
      if self.options[:copy_to_versions] == false
        self
      else
        copy = self.clone
        copy.suffix = version
      
        if copy_file(File.join(self.dir, copy.filename))
          return copy
        end
      end
    end

    # Checks if there's already an existing version of this file and moves it to a backup copy if needed. This is used at the
    # start of the copy_to_version method. The backup filename is the regular filename followed by the current timestamp (seconds
    # since epoch).
    def backup_existing_file(file_path)
      FileUtils.move(file_path, "#{file_path}-#{Time.now.to_i.to_s}")
    end
    
  end
  
end