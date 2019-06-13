#require 'mongrel_cluster/recipes' 
require 'bundler/capistrano'
require "rvm/capistrano"

set :application, "expo"
set :deploy_to, "/usr/local/apps/#{application}"
set :user, "joshlin"
#set :runner, "root"
set :use_sudo, true

ssh_options[:forward_agent] = true # Tell cap your own private keys for git and use agent forwarding with this command.

default_run_options[:pty] = true # Must be set for the password prompt from git to work

set :repository,  "git@github.com:uwexpd/expo.git"
set :scm, "git"
set :branch, 'master'
set :deploy_via, :remote_cache
set :keep_releases, 10

set :rvm_ruby_string, "1.8.7" # set up which rvm ruby to use in server

server "expd.uaa.washington.edu", :app, :web, :db, :primary => true
#role :web, "expo.uaa.washington.edu"                          # Your HTTP server, Apache/etc
#role :app, "expo.uaa.washington.edu"                          # This may be the same as your `Web` server
#role :db,  "expo.uaa.washington.edu", :primary => true        # This is where Rails migrations will run

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
    task :start, :roles => :app do
      run "touch #{current_release}/tmp/restart.txt"
    end

    task :stop, :roles => :app do
      # Do nothing.
    end

    desc "Restart Application"
    task :restart, :roles => :app do
      run "touch #{current_release}/tmp/restart.txt"
    end
end

namespace :deploy do     
  desc "[internal] Link database.yml, security certs, files, and shared images to deployed release."
  task :config_symlink, :except => { :no_release => true } do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    run "ln -nfs #{shared_path}/config/email.yml #{release_path}/config/email.yml"
    run "ln -nfs #{shared_path}/config/certs #{release_path}/config/certs"
    run "ln -nfs #{shared_path}/files #{release_path}/files"
    run "ln -nfs #{shared_path}/images #{release_path}/public/images/shared"
    run "ln -nfs #{current_release}/public #{current_release}/public/expo"  
  end  
end

after "deploy:finalize_update", "deploy:config_symlink", "deploy:cleanup"

# Using hoptoad_notifier
# Dir[File.join(File.dirname(__FILE__), '..', 'vendor', 'gems', 'hoptoad_notifier-*')].each do |vendored_notifier|
#   $: << File.join(vendored_notifier, 'lib')
# end
# 
# require 'hoptoad_notifier/capistrano'
