source "https://rubygems.org"
gem "rails", "2.3.5"
gem "mongrel"
gem "mongrel_cluster"
gem "will_paginate", '~> 2.3.11'
gem "json"
gem "sanitize"
gem "rtex"
gem "calendar_date_select"
gem "hoe", "~> 2.3.3" # dependency with gem version 1.3.7
gem "RedCloth", "~> 4.2.9 " # related to composite_primary_keys (converting Textile into HTML)
gem "htmldoc"
gem "rcov"
gem "hoptoad_notifier"
gem "spreadsheet"
gem "nokogiri"
gem "addressable","~> 2.1.0"
gem "pdf-writer"
gem "rdoc", "~> 2.4.3"
gem "rmagick"
gem "daemons"
gem "acts_as_strip", "~> 1.0.0"
# Begin For UWSDB
gem "dbi"
gem "dbd-odbc"
gem "ruby-odbc"
gem "activerecord-odbc-adapter", "~> 2.0"
gem "composite_primary_keys"
# End 
gem "factory_girl", "~> 1.2.2" # TODO upgrade to "~> 2.0.5"
#gem "thoughtbot-factory_girl", :lib => 'factory_girl', :source => 'http://gems.github.com'
gem "rspec", "~> 1.2.9" # dependecy with hoe 2.3.3
gem "rspec-rails", "~> 1.2.7.1" # dependecy with rspec
gem "mail"

# Error report
gem "exception_notification", "~> 2.3.3"


group :production do  
  gem "omniauth-shibboleth"
  gem "mysql"
  #gem 'mysql2', '< 0.3'
end

group :development do
  gem "awesome_print", "~> 1.2.0"
  gem "capistrano"
  gem 'rvm-capistrano', :require => false
  gem "thin"
  gem "pry", "~> 0.9.12.2"
  gem "request-log-analyzer"
  gem "sevenwire-rest-client"
  gem "log4r"
  gem 'brakeman', :require => false
end

group :test do
  gem "database_cleaner", ">= 0.9.1"
end