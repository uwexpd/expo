class Apply::ConfirmationController < ApplyController
  
  skip_before_filter :redirect_to_group_member_area, :display_submitted_note
  before_filter :assign_applicant_object
  before_filter :ensure_eligible_for_confirmation
  
  def index

  end
  
  def confirm
    if params[:confirmation]
      @confirmer.update_attribute(:confirmed, params[:confirmation][:confirmed])
      if @confirmer.confirmed?
        @user_application.set_status "confirmed" unless @is_group_member
        #redirect_to :action => "contact_info" and return
        redirect_to :action => "workshops" and return
      else
        @user_application.set_status "cancelled" unless @is_group_member
        redirect_to apply_url(@offering) and return
      end
    else
      flash[:error] = "Please make a selection."
      redirect_to :action => 'index'
    end
  end
  
  def contact_info
    if params[:no_updates]
      @confirmer.person.require_validations = true
      @confirmer.person.require_student_validations = true
      @confirmer.person.contact_info_updated_at = Time.now
      if @confirmer.person.save
        redirect_to :action => "workshops" and return
      end
    end
    if params[:person]
      @confirmer.person.require_validations = true
      @confirmer.person.require_student_validations = true
      if @confirmer.person.update_attributes(params[:person])
        redirect_to :action => "workshops"
      end
    end
  end
  
  def workshops
    @event = @user_application.application_type.workshop_event rescue nil
    if @event.nil?
      flash[:error] = "Your application type does not have any associated workshops."
      redirect_to :action => "index" and return
    end
  end

  def nominate
    if params[:nomination]
      @confirmer.validate_nominated_mentor = true
      allowable_fields = %w( nominated_mentor_id nominated_mentor_explanation )
      nomination_attributes = params[:nomination].delete_if{|key,v| !allowable_fields.include?(key)}
      if @confirmer.update_attributes(nomination_attributes)
        flash[:notice] = "Thanks for nominating your mentor!"
        redirect_to :action => "theme"
      end
    end
  end
  
  def theme
    if params[:theme]
      @confirmer.validate_theme_responses = true
      allowable_fields = %w( theme_response theme_response2 theme_response3)
      theme_attribtues = params[:theme].delete_if{|key,v| !allowable_fields.include?(key)}
      if @confirmer.update_attributes(params[:theme])
        flash[:notice] = "Thank you for your response!" unless params[:theme][:theme_response].blank?
        redirect_to :action => 'requests'
      end
    end
  end
  
  def proceedings
    if params[:proceedings]
      @confirmer.update_attribute(:requests_printed_program, params[:proceedings][:requests_printed_program])
      redirect_to apply_url(@offering) and return
    end
  end
  
  def requests
    if params[:requests]
      @user_application.update_attribute(:special_requests, params[:requests][:special_requests])
      redirect_to apply_url(@offering) and return
    end
  end
  
  protected
  
  # Since both primary applicants and group members have to go through the confirmation process independently,
  # the relevant database fields exist the same in both models. This method assigns +@confirmer+ to be the current
  # +@group_member+ object if +@is_group_member+ evaluates to true, or +@user_application+ otherwise.
  def assign_applicant_object
    @confirmer = @is_group_member ? @group_member : @user_application
  end
  
  # Ensures that this application is eligible to go through the confirmation by checking that the application
  # has passed the +fully_accepted+ status.
  def ensure_eligible_for_confirmation
    unless @offering.confirmations_allowed?
      flash[:error] = "We're sorry, but the confirmation process is currently disabled."
      redirect_to apply_url(@offering) and return
    end
    unless @user_application.passed_status?("fully_accepted")
      flash[:error] = "You cannot go through the confirmation process until your application has been fully accepted."
      redirect_to apply_url(@offering) and return
    end
  end
  
end