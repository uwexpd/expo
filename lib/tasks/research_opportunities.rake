require 'csv'

desc "Import for migration of research opportunities data from csv file"
task :import_research_opportunities => :environment do
    print "Parsing CSV file...."    
    file_path = "tmp/tblOpportunities.csv"
    print "(file path: #{file_path})\n"
    
    lineno = 0
    
    opportunity_file = CSV.open(file_path, 'r', ?,, ?\r)  
   
    puts "Start to add research opportunity information..."
     
    opportunity_file.each do |row|
      lineno += 1
      next if lineno == 1


      active         = row[0]
      removed        = row[1]
      id             = row[2].to_i
      name           = row[3].try(:strip)
      email          = row[4].try(:strip)
      department     = row[5].try(:strip)
      title          = row[6].try(:strip)
      description    = row[7].try(:strip)
      requirements   = row[8].try(:strip)
      research_area1 = row[9].try(:strip).to_i
      research_area2 = row[10].try(:strip).to_i
      research_area3 = row[11].try(:strip).to_i
      research_area4 = row[12].try(:strip).to_i
      submit_time    = row[13].try(:strip).to_datetime unless row[13].blank?      
      end_date       = Date.parse(row[14].try(:strip)) unless row[14].blank? 
      

      unless id.blank?
        opportunity = ResearchOpportunities.find_or_create_by_id(id)
        opportunity.update_attributes(:name => name,
                                      :email => email,
                                      :department => department,
                                      :title => title,
                                      :description => description,
                                      :requirements => requirements,
                                      :research_area1 => research_area1,
                                      :research_area2 => research_area2,
                                      :research_area3 => research_area3,
                                      :research_area4 => research_area4,
                                      :end_date => end_date,
                                      :active => active,
                                      :removed => removed,
                                      :created_at => submit_time
                                      )
      end
            
    end
            
    puts "Updated #{lineno} Research Opportunities."
    
end