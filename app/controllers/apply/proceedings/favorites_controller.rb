class Apply::Proceedings::FavoritesController < Apply::ProceedingsController

  before_filter :login_required, :only => [:save]
  before_filter :adjust_format_for_iphone

  def index
    @abstracts = ApplicationForOffering.find(@favorite_abstract_ids, :include => [:offering_session])
    @abstracts = @abstracts.sort_by{|x| "#{x.offering_session.try(:session_group).to_s}#{x.offering_session.try(:identifier).to_s}"}    
    
    merge_file = params[:header] == 'false' ? nil : @offering.proceedings_pdf_letterhead.try(:path)

    respond_to do |format|
      format.html
      format.iphone
      format.pdf { render :layout => 'proceedings', :merge_with => merge_file }
    end
  end

  
  def create
    @ids = params[:id].include?(",") ? params[:id].gsub(/\[|\]/,"").split(",").collect(&:to_i) : params[:id]
    @application_for_offerings = [@offering.application_for_offerings.find(@ids)].flatten
    for application_for_offering in @application_for_offerings
      @proceedings_favorite = ProceedingsFavorite.new(:application_for_offering_id => application_for_offering.try(:id))
      if logged_in?
        @proceedings_favorite.user_id = current_user.id
      else
        @proceedings_favorite.session_id = request.session_options[:id]
      end
      @proceedings_favorite.save! if @proceedings_favorite.valid?
    end    
    
    fetch_favorite_abstracts
    
    respond_to do |format|
      format.html { redirect_to :back }
      format.js
    end
  end

  def destroy
    @application_for_offering = @offering.application_for_offerings.find(params[:id])
    fetch_favorite_abstracts
    
    @abstract_to_destroy = @favorite_abstracts.select{|a| a.application_for_offering_id == @application_for_offering.id }
    @abstract_to_destroy.first.destroy if @abstract_to_destroy

    fetch_favorite_abstracts
    
    respond_to do |format|
      format.html { redirect_to :back }
      format.js
    end
  end

  # Transfer favorites that are stored in the session into the user's record.
  def save
    transfer = ProceedingsFavorite.find(:all, :conditions => { :session_id => request.session_options[:id] })
    for t in transfer
      t.update_attribute(:user_id, current_user.id) if logged_in?
    end
    redirect_to :action => "index"
  end

  
end