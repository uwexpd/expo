class Admin::TicketsController < Admin::BaseController
  
  before_filter :add_tickets_breadcrumbs
  
  def index
    q_params = { :q => "sort:state" }
    q_params[:page] = params[:page] if params[:page]
    @tickets = Ticket.find(:all, :params => q_params )
    @current_page = params[:page] ? params[:page] : 1
  end
  
  def show
    @ticket = Ticket.find(params[:id])
    session[:breadcrumbs].add "##{@ticket.number} - #{@ticket.title}"
    
    respond_to do |format|
      format.html
      format.xml { render :xml => @ticket.to_xml }
    end
  end

  def update
    @ticket = Ticket.find(params[:id])
    body_prefix = "h4. Comment from #{@current_user.fullname}\n"
    @ticket.body = body_prefix + params[:ticket][:body]
    @ticket.save
    redirect_to admin_ticket_path(@ticket)
  end
  
  def milestone
    @milestone = Milestone.find(params[:id])
    @tickets = @milestone.tickets
    session[:breadcrumbs].add "#{@milestone.title}"
  end
  
  protected
  
  def add_tickets_breadcrumbs
    session[:breadcrumbs].add "Tickets", admin_tickets_url
  end
  
end