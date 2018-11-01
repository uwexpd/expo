# Be sure to restart your web server when you modify this file.

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.5' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here

  # Allow for models in subdirectories off /models/
  #config.load_paths << "#{RAILS_ROOT}/app/models/studentdb"
  config.load_paths += Dir["#{RAILS_ROOT}/app/models/[a-z]*"]
  config.load_paths += Dir["#{RAILS_ROOT}/app/models/[a-z]*/[a-z]*"]
  config.load_paths += Dir["#{RAILS_ROOT}/vendor/plugins/strip_attributes/"]
  config.load_paths += %W( #{RAILS_ROOT}/app/sweepers )
  
  # Setup a secret to ensure integrity of session cookies (new in rails 2.0 apparently)
  config.action_controller.session = { :key => "_expo_session", :secret => "mGg44KjlwppO2HXXmatTh9d3413501ba3117948a2441574e4e5df" }

  # Skip frameworks you're not going to use (only works if using vendor/rails)
  # config.frameworks -= [ :action_web_service, :action_mailer ]

  # Only load the plugins named here, by default all plugins in vendor/plugins are loaded
  # config.plugins = %W( exception_notification ssl_requirement )

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Force all environments to use the same logger level
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Use the database for sessions instead of the file system
  # (create the session table with 'rake db:sessions:create')
  config.action_controller.session_store = :active_record_store

  # Setup the cache store
  config.cache_store = :file_store, "/tmp/cache"

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector
  config.active_record.observers = "ApplicationForOfferingSweeper", "ServiceLearningPlacementSweeper"

  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc

  # Add new inflection rules using the following format
  # (all these examples are active by default):
  # Inflector.inflections do |inflect|
  #   inflect.plural /^(ox)$/i, '\1en'
  #   inflect.singular /^(ox)en/i, '\1'
  #   inflect.irregular 'person', 'people'
  #   inflect.uncountable %w( fish sheep )
  # end

  # See Rails::Configuration for more options
  
  # Require gem dependencies
#  config.gem 'resource_controller'

  # config.gem 'composite_primary_keys'
  #   config.gem 'mislav-will_paginate', :version => '~> 2.3.11', :lib => 'will_paginate', :source => 'http://gems.github.com'
  #   config.gem "sanitize"
  #   config.gem 'rtex'
  #   config.gem "calendar_date_select"  
  #   config.gem "thoughtbot-factory_girl", :lib => "factory_girl", :source => "http://gems.github.com"
  #   config.gem "RedCloth"
  #   config.gem "htmldoc"
  #   config.gem "rcov"
  #   config.gem "hoptoad_notifier"
  #   config.gem "spreadsheet"
  #   config.gem "nokogiri"
  
end

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf
# Mime::Type.register "application/x-mobile", :mobile
# We use config/initializers/mime_types.rb for this

# Setup our constants for the app
require 'yaml'
CONSTANTS = YAML::load(ERB.new((IO.read("#{RAILS_ROOT}/config/constants.yml"))).result).symbolize_keys

# Setup Exception notifier
ExceptionNotification::Notifier.exception_recipients = %w(expohelp@u.washington.edu)
ExceptionNotification::Notifier.sender_address = %("EXP-Online" <expohelp@u.washington.edu>)
ExceptionNotification::Notifier.email_prefix = "[ERROR] "
# ExceptionNotifier.exception_recipients = %w(expohelp@u.washington.edu)
# ExceptionNotifier.sender_address = %("EXP-Online" <expohelp@u.washington.edu>)
# ExceptionNotifier.email_prefix = "[error] "

# Load subfolders of lib
Dir["#{RAILS_ROOT}/lib/exceptions/**/*.rb"].each do |file|
  load file
end

# Disable the requirement to have the "indicator" when using the remote_helpers plugin. Need to override this in each remote function call.
RemoteIndicator.enable_all = false

# Load other custom libraries
require 'array_math'
require 'uw_calendar'
require 'string_helper'

# Deep Clone capability
require 'deep_clone'
ActiveRecord::Base.send(:include, DeepClone)

# Override upload_column in lib
require "#{RAILS_ROOT}/lib/upload_column/uploaded_file.rb"
require "#{RAILS_ROOT}/lib/upload_column/active_record_extension.rb"

# Set MySQL to use ANSI mode -- this allows normal quotes in queries
class ActiveRecord::ConnectionAdapters::MysqlAdapter
  alias :connect_no_sql_mode :connect
  def connect
    connect_no_sql_mode
    execute("SET sql_mode = 'ANSI'")
  end
end

# Include your application configuration below
require 'composite_primary_keys'

#require 'active_ldap'
 
load "#{RAILS_ROOT}/lib/date_helper.rb"

CalendarDateSelect.format = :hyphen_ampm

