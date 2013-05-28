class Admin::Communicate::ContactHistoryController < Admin::BaseController
  before_filter :add_to_breadcrumbs
  
  def index
    @contacts = []
    if params[:to]
      if !params[:to].is_numeric? #params[:to].to_i.to_s != params[:to]
        # This is taking too much resources to perform, change tonly use person id for finding. 
        # TODO: search by name and let users to choose which person to search.
        # @contacts = EmailContact.to_address(params[:to])
        # @title = "Contacts to #{params[:to]}"
        @error = "Please enter an expo person id."
      else
        @contacts = ContactHistory.to_person(params[:to]).all :order => "updated_at DESC", :include => :person
        @title = "Contacts to #{Person.find(params[:to]).fullname}"
      end
      @contacts = @contacts.paginate :page => params[:page]
    else
      @contacts = ContactHistory.from_user(@current_user.id).paginate :order => "updated_at DESC", :page => params[:page]
      @title = "Sent By Me"
    end
    flash.now[:error] = "No contact records were found." if @contacts.empty?
    session[:breadcrumbs].add @title
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @contacts }
    end
  end

  def from_me
    @contacts = ContactHistory.from_user(@current_user.id).paginate :order => "updated_at DESC", :page => params[:page]
    @title = "Sent By Me"
    session[:breadcrumbs].add "Sent By Me"
    render :action => 'index'
  end

  def show
    @contact = ContactHistory.find(params[:id])
    session[:breadcrumbs].add "View"

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @contact }
    end
  end

  def requeue
    @contact = ContactHistory.find(params[:id])
    session[:return_to_after_email_queue] = request.referer
    redirect_to edit_admin_communicate_email_queue_url(@contact.requeue) and return
  end

  protected
  
  def add_to_breadcrumbs
    session[:breadcrumbs].add "Contact History", :action => 'index'
  end
  
end
