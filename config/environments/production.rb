# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host                  = "http://assets.example.com"

# Disable delivery errors, bad email addresses will be ignored
# config.action_mailer.raise_delivery_errors = false

# Configure a relative url to use for links to this app while in production mode
config.action_controller.relative_url_root = '/expo'

# Only use SSL for session data
ActionController::Base.session_options[:session_secure] = true

#require 'active_ldap' # disabled after upgrade to rails 2.3.4

config.action_mailer.delivery_method = :smtp
config.action_mailer.default_url_options = { :host => "expo.uw.edu", :protocol => 'https' }
config.action_mailer.smtp_settings = YAML.load_file("#{Rails.root}/config/email.yml")[Rails.env].symbolize_keys