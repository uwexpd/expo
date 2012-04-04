# Handles the automated tasks of the equipment reservation system.
class EquipmentReservationSweeper < ActiveRecord::Base
  self.abstract_class = true
  
  # Designed to be run daily at 4 pm. 
  # 
  # Checks all currently checked-out reservations to see if they're late. For all late returns:
  # 
  # 1. E-mail late notice to the student (varies depending on how late it is)
  # 2. E-mail EXP equipment committee and CC unit equipment reservation approvers
  # 3. Apply restrictions to the student account (depending on how late it is)
  # 4. Add a note to the student record.
  def self.process_late_returns
    EquipmentReservation.in_status(:checked_out).each(&:status!)
    
    EquipmentReservation.in_status(:late).each do |reservation|
      reservation.send_late_notice!
      reservation.send_staff_late_notice!
      reservation.apply_late_penalties!
    end

    true
  end
  
  # Designed to be run every day at 6 pm.
  # 
  # Sends out reminder emails about tomorrow's expected returns and pickups.
  def self.tomorrow_reminders
    EquipmentReservation.tomorrows_checkouts.each(&:send_checkout_reminder!)
    EquipmentReservation.tomorrows_checkins.each(&:send_checkin_reminder!)
    true
  end
  
  # Designed to be run every day at 9 am.
  # 
  # Checks all of today and tomorrow's checkouts to see if there are any equipments marked as not ready for checkout. If we find
  # any equipment that's not ready, we send an email to the EXP equipment committee so they can take action!
  def self.equipment_not_ready_check
    EquipmentReservation.todays_checkouts.each do |reservation|
      reservation.send_not_ready_notice! unless reservation.ready_for_checkout?
    end
    EquipmentReservation.tomorrows_checkouts_excluding_weekends.each do |reservation|
      reservation.send_not_ready_notice! unless reservation.ready_for_checkout?
    end
    true
  end
  
end