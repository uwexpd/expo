class ApplicationForOfferingSweeper < ActionController::Caching::Sweeper
  observe ApplicationForOffering
  
  def after_save(app)
    expire_fragment(:controller => 'proceedings', :action => 'abstract', :id => app.id)
    expire_fragment(:controller => 'proceedings', :action => 'abstract_presenters', :id => app.id)
    expire_fragment(:controller => 'proceedings', :action => 'abstract_text', :id => app.id)
  end
  
end