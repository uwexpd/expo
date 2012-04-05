class Admin::Communicate::ContactHistoryController < Admin::BaseController
  before_filter :add_to_breadcrumbs
  
  def index
    @contacts = []
    if params[:to]
      if params[:to].to_i.to_s != params[:to]
        @contacts = EmailContact.to_address(params[:to])
        @title = "Contacts to #{params[:to]}"
        session[:breadcrumbs].add @title
      else
        @contacts = ContactHistory.to_person(params[:to]).all :order => "updated_at DESC", :include => :person
        @title = "Contacts to #{Person.find(params[:to]).fullname}"
        session[:breadcrumbs].add @title
      end
      @contacts = @contacts.paginate :page => params[:page]
    else
      @contacts = ContactHistory.paginate :order => "updated_at DESC", :page => params[:page], :include => :person
    end
    flash[:error] = "No contact history records found." if @contacts.empty?

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
