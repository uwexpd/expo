# Settings specified here will take precedence over those in config/environment.rb

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_controller.perform_caching             = false
#config.action_view.cache_template_extensions         = false
config.action_view.debug_rjs                         = true

# Turn on debugging
#require "ruby-debug"

#require 'active_ldap'  ## disabled after upgrade to rails 2.3.4

# show logs for console and rake tasks
# config.logger = Logger.new(STDOUT)

# ActionMailer Config
config.action_mailer.perform_deliveries = false # Set it to true to send the email in dev mode
config.action_mailer.raise_delivery_errors = false
config.action_mailer.delivery_method = :smtp
config.action_mailer.default_url_options = { :host => "localhost:3000" }
config.action_mailer.smtp_settings = YAML.load_file("#{Rails.root}/config/email.yml")[Rails.env].symbolize_keys