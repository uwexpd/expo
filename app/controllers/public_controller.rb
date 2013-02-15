class PublicController < ApplicationController
  skip_before_filter :login_required
  before_filter :fetch_offering , :only => [:scholarslist]
      
  def scholarslist
    @awardees = @offering.application_for_offerings.awarded    
    
    respond_to do |format|
      format.html # scholarslist.html.erb      
    end
  end
  
  protected
  
  def fetch_offering
    @offering = Offering.find params[:id]
  end
  
end