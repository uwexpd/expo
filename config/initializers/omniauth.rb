if RAILS_ENV == 'production'
  ActionController::Dispatcher.middleware.use OmniAuth::Builder do
    provider :shibboleth, {
      :debug => false,
      :extra_fields => [:"unscoped-affiliation", :entitlement, :uwNetID, :uwRegID]
    }
  end
end