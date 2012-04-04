namespace :report do
  namespace :apply do

    desc "Get list of award amounts for a specific Offering"
    task :award_amounts => :environment do
      puts "Please specify an offering_id" and return unless ENV['offering_id']
      o = Offering.find ENV['offering_id']
      o.application_for_offerings.awarded.sort.each do |a|
        @display = true
        # a.awards.valid.each do |award|
        #   @display = true if award.amount_disbersed < 2000.00 rescue true
        # end
        if @display
          puts "#{a.fullname} (#{a.person.email})"
          a.awards.valid.each do |award|
            award_line = []
            award_line << "R: " + ('%.2f'%award.amount_requested rescue 0).to_s.ljust(12)
            award_line << "A: " + ('%.2f'%award.amount_awarded rescue 0).to_s.ljust(12)
            award_line << "F: " + ('%.2f'%award.amount_approved rescue 0).to_s.ljust(12)
            award_line << "D: " + ('%.2f'%award.amount_disbersed rescue 0).to_s.ljust(12)
            award_line << " (#{award.disbersement_type.name})" if award.disbersement_type
            puts "  ##{award.id.to_s.ljust(6)} #{award.requested_quarter.title.ljust(13)} #{award_line}"
          end
          puts ""
        end
      end
    end

  end
end