class ApplicationForOfferingSweeper < ActionController::Caching::Sweeper
  include ActionController::UrlWriter
  observe ApplicationForOffering, ApplicationMentor, ApplicationGroupMember

  
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
    # iphone: views/expo.uw.edu/apply/706/proceedings/result/127201.iphone?action_suffix=abstract_presenters
    offering_id = app.offering_id rescue app.offering.id
    app_id = app.class.name == "ApplicationForOffering" ? app.id : app.application_for_offering.id

    ['abstract_presenters','abstract_text'].each do |action_suffix|
      url = url_for(:controller => "apply/#{offering_id}/proceedings", :action => 'result', :action_suffix => action_suffix, :id => app_id, :host => CONSTANTS[:base_url_host])

      url_iphone = url_for(:controller => "apply/#{offering_id}/proceedings", :action => 'result', :action_suffix => action_suffix, :id => app_id, :host => CONSTANTS[:base_url_host], :format => :iphone)

      fragment_name = url[7..-1] # Remove 'http://'
      fragment_name_iphone = url_iphone[7..-1]

      # Rails.logger.info "fragment_name => #{fragment_name}"
      # Rails.logger.info "fragment_name_iphone => #{fragment_name_iphone}"
      Rails.cache.delete("views/#{fragment_name}")
      Rails.cache.delete("views/#{fragment_name_iphone}")
    end

    # This does not work....
    #ActionController::Base.new.expire_fragment(:controller => 'proceedings', :action => 'result', :action_suffix => 'abstract_text', :id => app.id)
    #ActionController::Base.new.expire_fragment(:controller => 'proceedings', :action => 'result', :action_suffix => 'abstract_text', :id => app.id)
  end
  
end