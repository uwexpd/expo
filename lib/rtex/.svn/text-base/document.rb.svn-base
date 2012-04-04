module RTeX
  
  class Document
        
    #######
    private
    #######
    
    def process!
      unless `#{processor} --interaction=nonstopmode '#{source_file}' #{@options[:shell_redirect]}`
        raise GenerationError, "Could not generate PDF using #{processor}"      
      end
      postprocess_merge! if postprocessing?
    end
    
    def postprocess_merge!
      raise GenerationError, "Could not find merge file #{@options[:merge_with]}" unless File.exists?(@options[:merge_with])

      burst_pages!
      stamp_first_page!
      combine_pages!
    end

    def burst_pages!
      puts `pdftk #{File.expand_path(result_file)} burst output #{File.expand_path(result_file)}-pg_%04d.pdf`
    end

    def stamp_first_page!
      puts `pdftk #{File.expand_path(result_file)}-pg_0001.pdf stamp #{@options[:merge_with]} output #{File.expand_path(result_file)}-stamped`
      puts `mv #{File.expand_path(result_file)}-stamped #{File.expand_path(result_file)}-pg_0001.pdf`
    end

    def combine_pages!
      puts `pdftk #{File.expand_path(result_file)}-pg_*.pdf cat output #{File.expand_path(result_file)}`
    end
    

    def postprocessing?
      !@options[:merge_with].nil?
    end
    
  end

end
