namespace :cron do
  namespace :service_learning do
    desc "Unplace students who are placed in service-learning positions for the current quarter but no longer enrolled in the associated course(s)."
    task :unplace_unenrolled_students => :environment do
      puts "Finding placements with unenrolled students..."
      ActiveRecord::Base.connection.execute("SET sql_mode = 'ANSI'")
      all_placements = Quarter.current_quarter.service_learning_placements
      all_placements.each do |p|
        if p.filled? && p.allocated? && !p.person.enrolled_service_learning_courses(Quarter.current_quarter, nil).include?(p.course)
            print "Un-placing student: #{p.inspect}"
            p.update_attribute(:person_id, nil)
            print "done.\r\n"
        end
      end      
    end
  end
  
  namespace :equipment_reservations do  
    desc "Process late returns (daily at 4 pm)"
    task :process_late_returns => :environment do
      puts "Processing late returns..."
      EquipmentReservationSweeper.process_late_returns
    end
    
    desc "Send tomorrow reminders (daily at 6 pm)"
    task :tomorrow_reminders => :environment do
      puts "Sending tomorrow's reminders..."
      EquipmentReservationSweeper.tomorrow_reminders
    end
    
    desc "Send equipment not ready check (daily at 9 am)"
    task :equipment_not_ready_check => :environment do
      puts "Sending equipment not ready checks..."
      EquipmentReservationSweeper.equipment_not_ready_check
    end
  end
  
  namespace :users do
    desc "Remove old session history"
    task :remove_old_session_history => :environment do
      STDOUT.sync = true
      puts "Removing session history older than one month..."
      deleted = SessionHistory.delete_all ["created_at < ?", 1.month.ago]
      puts "Deleted #{deleted} rows."
    end
  end
  
end