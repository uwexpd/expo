ActionController::Dispatcher.middleware.use OmniAuth::Builder do
  provider :shibboleth, :extra_fields => [:"unscoped-affiliation", :entitlement, :uwNetID, :uwRegID]
end