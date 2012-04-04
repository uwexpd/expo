class Admin::Offerings::Statuses::EmailsController < Admin::Offerings::StatusesController
  
  before_filter :fetch_status
  before_filter :add_emails_breadcrumbs
  
  def index
    @emails = @status.emails.find :all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @emails }
    end
  end

  def show
    @email = @status.emails.find(params[:id])
    session[:breadcrumbs].add "#{@email.send_to.titleize}"

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @email }
    end
  end

  def new
    @email = @status.emails.new
    session[:breadcrumbs].add "New"

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @email }
    end
  end

  def edit
    @email = @status.emails.find(params[:id])
    session[:breadcrumbs].add "#{@email.send_to.titleize}", offering_status_email_url(@offering, @status, @email)
    session[:breadcrumbs].add "Edit"
  end

  def create
    @email = @status.emails.new(params[:email])

    respond_to do |format|
      if @email.save
        flash[:notice] = '@status.emails was successfully created.'
        format.html { redirect_to(offering_status_email_url(@offering, @status, @email)) }
        format.xml  { render :xml => @email, :status => :created, :location => @email }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @email.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @email = @status.emails.find(params[:id])

    respond_to do |format|
      if @email.update_attributes(params[:email])
        flash[:notice] = '@status.emails was successfully updated.'
        format.html { redirect_to offering_status_email_url(@offering, @status, @email) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @email.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @email = @status.emails.find(params[:id])
    @email.destroy

    respond_to do |format|
      format.html { redirect_to offering_status_emails_url(@offering, @status) }
      format.xml  { head :ok }
    end
  end
  
  
  protected

  def fetch_status
    @status = @offering.statuses.find params[:status_id]
    session[:breadcrumbs].add "#{@status.private_title}", offering_status_path(@offering, @status)
  end

  def add_emails_breadcrumbs
    session[:breadcrumbs].add "E-mails", offering_status_emails_path(@offering, @status)
  end
  
end