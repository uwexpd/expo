class ApplicationForOfferingSweeper < ActionController::Caching::Sweeper
  include ActionController::UrlWriter
  observe ApplicationForOffering
  
  def after_save(app)
	expire_cache_for(app)
  end

  def after_destroy(app)
	expire_cache_for(app)
  end

  private

  def expire_cache_for(app)
    # @controller ||= ActionController::Base.new
    # expire_fragment([:abstract_presenters , app])
    # expire_fragment([:abstract_text , app])
    ['abstract_presenters','abstract_text'].each do |action_suffix|
      url = url_for(:controller => "apply/#{app.offering_id}/proceedings", :action => 'result', :action_suffix => action_suffix, :id => app.id, :host => CONSTANTS[:base_system_url])
      # Remove 'http://'
      fragment_name = url[7..-1]
      Rails.logger.debug "fragment_name => #{fragment_name}"
      Rails.cache.delete("views/#{fragment_name}")
    end

    # This does not work....
    #ActionController::Base.new.expire_fragment(:controller => 'proceedings', :action => 'result', :action_suffix => 'abstract_text', :id => app.id)
    #ActionController::Base.new.expire_fragment(:controller => 'proceedings', :action => 'result', :action_suffix => 'abstract_text', :id => app.id)
  end
  
end