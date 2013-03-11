source :rubygems
gem "rails", "2.3.5"
gem "mongrel"
gem "mongrel_cluster"
gem "will_paginate", '~> 2.3.11'
gem "json"
gem "sanitize"
gem "rtex"
gem "calendar_date_select"
gem "factory_girl", "~> 1.2.2"
gem "hoe", "~> 2.3.3" # dependency with gem version 1.3.7
gem "RedCloth"
gem "htmldoc"
gem "rcov"
gem "hoptoad_notifier"
gem "spreadsheet"
gem "nokogiri"
gem "addressable","~> 2.1.0"
gem "pdf-writer"
gem "composite_primary_keys"
gem "rdoc", "~> 2.4.3"
gem "rmagick"
gem "daemons"
# For UWSDB
gem "dbi"
gem "dbd-odbc"
gem "ruby-odbc"
gem "activerecord-odbc-adapter", "~> 2.0"
# End
gem "rspec", "~> 1.2.9" # dependecy with hoe 2.3.3
gem "rspec-rails", "~> 1.2.7.1" # dependecy with rspec


group :production do  
  gem "omniauth-shibboleth"
  gem "mysql"
  
end

group :development do
  # bundler requires these gems in development
  #gem "sqlite3-ruby", :require => "sqlite3"  
  gem "andrew311-activerecord-odbc-adapter"
  gem "capistrano"
  gem "thin"
end

group :test do
  # bundler requires these gems while running tests
  gem "database_cleaner", ">= 0.9.1"
end