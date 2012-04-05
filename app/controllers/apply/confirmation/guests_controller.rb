class Apply::Confirmation::GuestsController < Apply::ConfirmationController
  
  def index
    @guest = @confirmer.guests.new
  end
  
  def create
    @guest = @confirmer.guests.new(params[:guest])

    respond_to do |format|
      if @guest.save
        flash[:notice] = "#{@guest.fullname} was successfully added to your invite list."
        format.html { redirect_to(apply_confirmation_guests_url(@offering)) }
      else
        format.html { render :action => "index" }
      end
    end
  end

  def update
    @guest = @confirmer.guests.find(params[:id])

    respond_to do |format|
      if @guest.update_attributes(params[:guest])
        flash[:notice] = "#{@guest.fullname}'s details were successfully updated."
        format.html { redirect_to(apply_confirmation_guests_url(@offering)) }
      else
        format.html { render :action => "index" }
      end
    end
  end

  def destroy
    @guest = @confirmer.guests.find(params[:id])
    @guest.destroy
    flash[:notice] = "#{@guest.fullname} was successfully removed from your invite list."

    respond_to do |format|
      format.html { redirect_to(apply_confirmation_guests_url(@offering)) }
    end
  end

end