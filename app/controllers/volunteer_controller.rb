class VolunteerController < ApplicationController
  skip_before_filter :login_required
  before_filter :student_login_required_if_possible
  before_filter :check_if_contact_info_is_current

  def index
    @events = Event.public.sort

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @events }
    end
  end

  def event
    @event = Event.find(params[:id])
    apply_alternate_stylesheet(@event)

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @event }
    end
  end

  def signup
    @event = Event.find(params[:id])
    @person = @current_user.person
    
    if request.put?
      @signupable = @event.staff_position_shifts.find params[:shift_id] if params[:shift_id]
      @signupable = @event.staff_positions.find params[:position_id] if params[:position_id]
      @staff = @signupable.signup!(@person)
      valid = @staff.is_a?(Array) ? !@staff.collect(&:valid?).include?(false) : @staff.valid?
      if valid
        flash[:notice] = "Thanks for volunteering for #{@signupable.title}!"
      else
        render :action => "event" and return
      end
    end
    redirect_to params[:return_to] || :action => 'event'
  end

  def unsignup
    @event = Event.find(params[:id])
    @person = @current_user.person
    
    if request.delete?
      if params[:shift_id] # Signing up for a single shift
        @shift = @event.staff_position_shifts.find params[:shift_id]
        flash[:notice] = "We've successfully removed you from the #{@shift.title} position." if @shift.unsignup!(@person)
      elsif params[:position_id]
        @position = @event.staff_positions.find params[:position_id]
        flash[:notice] = "We've successfully removed you from the #{@position.title} position." if @position.unsignup!(@person)
      end
    end
    redirect_to params[:return_to] || :action => 'event'
  end

 
  # def attend
  #   @event = Event.find(params[:id])
  #   @time = @event.times.find(params[:time_id])
  #   if request.post?
  #     if @time.full?
  #       flash[:error] = "Sorry, but that time slot is full. Please choose another time slot."
  #     elsif invitee = @time.invite!(@current_user.person, { :attending => true })
  #       flash[:notice] = "Thank you for your RSVP!"
  #       invitee.send_confirmation_email
  #     else
  #       flash[:error] = "Something went wrong. Please try again."
  #     end
  #   end
  #   redirect_to params[:return_to] || :back
  # end
  # 
  # def unattend
  #   @event = Event.find(params[:id])
  #   @time = @event.times.find(params[:time_id])
  #   if request.delete?
  #     if @time.invite!(@current_user.person, { :attending => false })
  #       flash[:notice] = "We're sorry you'll no longer be joining us. Thank you for your reply."
  #     else
  #       flash[:error] = "Something went wrong. Please try again."
  #     end
  #   end
  #   redirect_to params[:return_to] || :back
  # end


  protected

  def apply_alternate_stylesheet(event)
    if event.offering && event.offering.alternate_stylesheet 
      return false unless File.exists?(File.join(RAILS_ROOT, 'public', 'stylesheets', "#{event.offering.alternate_stylesheet}.css"))
      @alternate_stylesheet = event.offering.alternate_stylesheet
    end
  end

end