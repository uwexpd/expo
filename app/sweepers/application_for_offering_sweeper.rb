class ApplicationForOfferingSweeper < ActionController::Caching::Sweeper
  observe ApplicationForOffering
  
  def after_save(app)
    expire_fragment(:controller => 'proceedings', :action => 'result', :action_suffix => 'abstract_presenters', :id => app.id)
    expire_fragment(:controller => 'proceedings', :action => 'result', :action_suffix => 'abstract_text',  :id => app.id)
  end
  
end