class Admin::PipelineMigrateController  < Admin::BaseController
	before_filter :add_pipeline_migrate_breadcrumbs
	
	def index
	  @schools = parse!
	  
	  respond_to do |format|
			format.html
		end
  end
	
	def show
		@schools = parse!
		@page = params[:id].to_i
		@school = @schools[@page]
		
		@neighborhoods = ["","North","North West","North East","West","Central", "South West", "South East"]
		
		@saved_info = nil
		if File.exist?( "files/pipeline_files/"+@page.to_s+".yaml" )
		  @saved_info = YAML::load( File.read( "files/pipeline_files/"+@page.to_s+".yaml" ) )
    end
    
    session[:breadcrumbs].add @school[:name]
    
		respond_to do |format|
			format.html
		end
	end
	
	def create_migrate_file
	  @values = params
	  @yaml_string = YAML::dump( @values )
	  
	  File.open("files/pipeline_files/"+@values[:p]+".yaml", "w") do |f|
      f.write @yaml_string
    end
    
	  respond_to do |format|
  	  format.js
    end
	end
  
	def parse!
	  
	  contents = File.read "files/pipeline_files/All_Orgs.txt"
	  schools_contents = contents.split("\n\n")
	  
	  schools = []
	  
	  schools_contents.each do |school_content|
	    
	    # get school name
	    lines = school_content.split("\n")
	    name = lines.first.strip
	  
        # split up the attributes
	    attributes_array = school_content.split(/^(.+?):/)
	    attributes_hash = {}
	    i = 0
	    temp_key = nil
		contact = false
		contact_num = ''
	    attributes_array.each do |a|
	      if i == 0
	        #nothing
	      elsif temp_key.nil?
	        temp_key = a.downcase.strip
        else
		    # make sure to call the phone contact phone when needed additional tutoring opportunities
		      if (temp_key.casecmp "school phone") == 0
		        temp_key = "phone"
		      end
		      if (temp_key.index "additional tutoring opportunities") == 0
		        temp_key = "additional tutoring opportunities"
		      end
		      if (temp_key.index "tutoring opportunities") == 0
		        temp_key = "tutoring opportunities"
		      end
			    if (temp_key.casecmp "contact") == 0
			      if contact
				      temp_key = "contact_two"
				      contact_num = '_two'
				    else
				      contact = true
				      contact_num = ''
			      end
			      
			      pos_split = a.split(',')
			      a = pos_split[0]
			      if pos_split.size > 1
			        attributes_hash["contact" + contact_num + " position"] = pos_split[1].strip
			      end
			    end
		      if contact 
				    if (temp_key.casecmp "phone") == 0
				      temp_key = "contact" + contact_num + " phone"
				    elsif (temp_key.casecmp "email") == 0
				      temp_key = "contact" + contact_num + " email"
				    end
			    end
		      unless attributes_hash[temp_key].nil?
			      temp_key = temp_key+i.to_s 
			    end
			    attributes_hash[temp_key] = a.strip
			    temp_key = nil
        end
	      i = i+1
      end
	  
      # save to the array 
	    school = {:name => name, :attributes => attributes_hash }
	    schools << school
	    
	  end
	    
	  #schools.each{|s| puts s[:name]; s[:attributes].each{|k,v| puts "   #{k.ljust(30)} : #{v[0..100]}"}}
	  
	  return schools
	end
	
	protected
  
  def add_pipeline_migrate_breadcrumbs
    session[:breadcrumbs].add "Pipeline Migrate", :action => 'index'
  end
  
end