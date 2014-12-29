require 'csv'

desc "Import for migration of research opportunities data from csv file"
task :import_research_opportunities => :environment do
    print "Parsing CSV file...."    
    file_path = "tmp/tblOpportunities_update.csv"
    print "(file path: #{file_path})\n"
    
    lineno = 0
    update_count = 0
    
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
      
      submit_time = submit_time.change(:year => 2014) if submit_time
      end_date = end_date.change(:year => 2014) if end_date
      
      unless id.blank?
        opportunity = ResearchOpportunity.find_or_create_by_id(id)
        if opportunity.update_attributes(:name => name,
                                      :email => email,
                                      :department => department,
                                      :title => title,
                                      :description => description,
                                      :requirements => requirements,
                                      :research_area1 => research_area1,
                                      :research_area2 => research_area2,
                                      :research_area3 => research_area3,
                                      :research_area4 => research_area4,
                                      :end_date => end_date, # NOTE that there is end_date_cannot_be_in_the_past validation in the ResearchOpportunity model
                                      :active => active,
                                      :removed => removed,
                                      :submitted => true,
                                      :created_at => submit_time
                                      )
          update_count += 1
        end
      end    

    end
            
    puts "Updated #{update_count} Research Opportunities."
    
end