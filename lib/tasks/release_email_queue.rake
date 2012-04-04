namespace :email_queue do

  desc "Release the specified messages from the EmailQueue"
  task :release => :environment do
    puts "Email queue release requested: #{Time.now}"
    email_queue_ids = ENV["EMAIL_QUEUE_IDS"].split(",")
    email_queue_ids.sort.each do |i|
      puts "** [email_queue:release] Releasing message #{i}"
      begin
        email = EmailQueue.find(i)
        email.release
      rescue ActiveRecord::RecordNotFound => e
        puts e.message
      rescue Exception => e
        email.update_attribute(:error_details, e.message)
      end
    end
  end
  
end