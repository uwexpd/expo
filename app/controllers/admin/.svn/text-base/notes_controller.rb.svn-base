class Admin::NotesController < Admin::BaseController
  
  before_filter :add_notes_breadcrumbs
  before_filter :verify_permissions, :only => [:edit, :update, :destroy]
  
  def edit
    @note = Note.find params[:id]
    session[:breadcrumbs].add "##{@note.id}"
  end

  def update
    @note = Note.find(params[:id])

    respond_to do |format|
      if @note.update_attributes(params[:note])
        flash[:notice] = "Successfully updated note."
        format.html { redirect_to(redirect_to_path || {:action => 'edit'}) and return }
        format.js
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.js
        format.xml  { render :xml => @note.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @note = Note.find(params[:id])
    @note.destroy

    respond_to do |format|
      format.html { redirect_to redirect_to_path }
      format.xml  { head :ok }
      format.js
    end
  end
    
  protected
  
  def add_notes_breadcrumbs
    session[:breadcrumbs].add "Notes", notes_url
  end

  def verify_permissions
    @note = Note.find params[:id]
    unless @note.allows?(@current_user)
      flash[:error] = "You do not have permission to view or edit that note."
      redirect_to(redirect_to_path || admin_welcome_path) and return
    end
  end
  
end
