class Admin::FavoritePagesController < Admin::BaseController
  
  def create
    @current_user.favorite_pages.create(:url => params[:url], :title => params[:title]) if params[:url] && params[:title]
    
    respond_to do |format|
      format.js
    end
  end

  def destroy
    @current_user.favorite_pages.find_by_url(params[:url]).destroy if params[:url]
    
    respond_to do |format|
      format.js
    end
  end
  
  def sort
    params[:favorite_pages].each_with_index do |id, index|
      FavoritePage.update_all(['position=?', index+1], ['id=?', id])
    end
    render :nothing => true
  end
  
end