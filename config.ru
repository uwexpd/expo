ENV["RAILS_ENV"] ||= ENV["RACK_ENV"]
# Require your environment file to bootstrap Rails
require ::File.dirname(__FILE__) + '/config/environment.rb'

# Serve static assets from RAILS_ROOT/public directory
# use Rails::Rack::Static
# Dispatch the request
run ActionController::Dispatcher.new