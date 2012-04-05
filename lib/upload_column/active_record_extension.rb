module UploadColumn
  module ActiveRecordExtension
    
    # Override built-in method so that we handle STI classes properly...
    def options_for_column(name)
      klass = self.class.respond_to?(:parent_class) ? self.class.parent_class : self.class
      return klass.reflect_on_upload_columns[name].options.reverse_merge(UploadColumn.configuration)
    end
    
  end
end