module UploadColumn
  
  UploadError = Class.new(StandardError) unless defined?(UploadError)
  ManipulationError = Class.new(UploadError) unless defined?(ManipulationError)
  
  module Manipulators
    
    module DocumentConverter
      
      def load_manipulator_dependencies #:nodoc:
        #require 'RMagick'
      end
      
      def process!(instruction = nil, &block)
        case instruction
        when :convert_to_pdf
          convert_to_pdf!
        when :stamp_pdf
          stamp_pdf!
        when :original
          stamp_pdf! if content_type == 'application/pdf' || self.versions[:original].path.include?("pdf")
        end
      end
        
      # Attempts to convert this file to PDF using OpenOffice.org. This command will set the LD_LIBRARY_PATH and then execute
      # a custom PHP script to do the conversion using the OOo API. The operation and its result are logged.
      # If the file is already a PDF, then we simply stamp the PDF and move on.
      def convert_to_pdf!
        if content_type == 'application/pdf'
          return stamp_pdf!
        else
          command = "export LD_LIBRARY_PATH=/opt/openoffice.org2.4_sdk/linux/lib:/opt/openoffice.org2.4/program/; #{RAILS_ROOT}/lib/pdfconvert/convert.php #{self.versions[:original].path} \"\" #{self.versions[:pdf].path}"
          RAILS_DEFAULT_LOGGER.info { "--Converting file to pdf:\n  Command: #{command}" }
          result = `#{command}`
          RAILS_DEFAULT_LOGGER.info { "#{result}" }
          RAILS_DEFAULT_LOGGER.info { "  --> Result: #{$?}" }
          out = $?

          if result.to_s.include?("couldn't connect to socket") || result.to_s.include?("error") || !out.success?
            Thread.current['pdf_conversion_error'] = "Could not convert document to PDF: #{result.to_s}"
          else
            Thread.current['pdf_conversion_error'] = nil
          end
          
          stamp_pdf! if out.success?
          return out
        end
      end
      
      # Uses pdftk to add a custom header to the file.
      def stamp_pdf!
        stamp_filename = self.instance.application_for_offering.composite_report.get_part(:stamp)
        command = "pdftk #{self.versions[:pdf].path} stamp #{stamp_filename} output #{self.versions[:pdf].path}-stamped"
        RAILS_DEFAULT_LOGGER.info { "Stamping PDF file:\n   #{command}"}
        res = `#{command}`
        out = $?
        if out.success?
          `mv #{self.versions[:pdf].path} #{self.versions[:pdf].path}-unstamped`
          `mv #{self.versions[:pdf].path}-stamped #{self.versions[:pdf].path}`
        end
        return out
      end
      
    end
    
  end  
  
end