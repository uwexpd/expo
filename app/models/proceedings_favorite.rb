# Allows users to identify individual applications as "favorites" when browsing the Apply#proceedings area. 
# These can then be grouped together on a single page or a single PDF for printing.
# 
# Since the proceedings are a public area, people who don't want to create a user to login can store their favorites
# in their session. In this case, the ProceedingsFavorite is linked using a session_id attribute instead of a
# user_id attribute.
class ProceedingsFavorite < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :application_for_offering
  
  validates_presence_of :application_for_offering_id
  
  validate :require_user_or_session, :require_unique_application
  
  def require_user_or_session
    errors.add_to_base "Either user ID or session ID are required" if session_id.blank? && user_id.blank?
  end
  
  def require_unique_application
    errors.add :application_id, "must be unique" if my_proceedings_favorites.collect(&:application_for_offering_id).include?(application_for_offering_id)
  end

  protected
  
  def my_proceedings_favorites
    if user
      user.proceedings_favorites.for(application_for_offering.try(:offering))
    else
      ProceedingsFavorite.find_all_by_session_id(session_id)
    end
  end
  
end
