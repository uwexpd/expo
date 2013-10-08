# Users can checkout equipment from the EXP equipment collection. This model defines each individual piece of equipment.
class Equipment < ActiveRecord::Base
  belongs_to :category, :class_name => "EquipmentCategory"
  has_many :reservation_equipments, :class_name => "EquipmentReservationEquipment"
  has_many :reservations, :through => :reservation_equipments do
    def submitted; find(:all, :conditions => { :submitted => true }); end
  end

  validates_presence_of :title, :tag, :equipment_category_id
  validates_uniqueness_of :tag

  named_scope :staff_only, :conditions => { :staff_only => true }
  
  image_column :local_picture, 
              :versions => { :thumb => "50x50", :large => "300x300" }, 
              :store_dir => proc{|record, file| "shared/equipment/#{record.id}/picture"} 

  # Default sort is by title
  def <=>(o)
    title <=> o.title rescue nil
  end
              
  # If this equipment's picture hasn't been set, try to use the category's picture instead, if it exists.
  def picture
    if local_picture.nil?
      category.picture if category
    else
      local_picture
    end
  end

  # Clears the local_picture attribute.
  def clear_picture=(value)
    self.update_attribute(:local_picture, nil) if value
  end
  
  # Returns true if this available for possible checkout for the given EquipmentReservation. Equipment that is 
  # *not* available does not even show up on the reservation request screen. Checks the following:
  # 
  # * Already reserved during that reservation's time range (taking into account the buffer days needed for this equipment's category)
  # * Reservation has not yet defined a start_date and end_date
  # * Not marked as "ready_for_checkout"
  # * A staff-only item for a non-staff checkout
  def available_for?(reservation)
    return false if staff_only? && !reservation.staff? # TODO handle staff reservations properly
    return false unless ready_for_checkout?
    return false if reservation.start_date.blank? || reservation.end_date.blank?
    if reservation.staff?
      reservation_start_date_with_buffer = reservation.start_date + 1.second
      reservation_end_date = reservation.end_date - 1.second
    else
      reservation_start_date_with_buffer = reservation.start_date - 1.day - (category.buffer_days_between_checkouts.to_i * 1.day)
      reservation_end_date = reservation.end_date
    end
    conditions = [['(start_date <= :start_date AND end_date >= :end_date)'],
                  ['(start_date <= :end_date AND end_date >= :end_date)'],
                  ['(start_date <= :start_date AND end_date >= :end_date)'],
                  ['(start_date >= :start_date AND end_date <= :end_date)'],
                  ['(start_date >= :start_date AND start_date <= :end_date)'],
               		['(end_date >= :start_date AND end_date <= :end_date)']]
    reservations.find(:all, :conditions => ["submitted = true
                                             AND equipment_reservation_id != #{reservation.id} 
                                             AND (#{conditions.join(" OR ")})", 
                                            { :start_date => reservation_start_date_with_buffer, :end_date => reservation_end_date }]).empty?
  end
    

  # Returns true if this piece of equipment is currently checked out (i.e., in a student's possession) by
  # determining if there is an EquipmentReservation for this equipment that has a status of "late" or "checked_out".
  def checked_out?
    !reservations.find(:all, :conditions => ["status = ? OR status = ?", 'late', 'checked_out']).empty?
  end
  
end
