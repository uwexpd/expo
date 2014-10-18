require 'mongrel_cluster/recipes'
require 'bundler/capistrano'

# $:.unshift(File.expand_path('./lib', ENV['rvm_path'])) # Add RVM's lib directory to the load path.
# set :rvm_type, :user
# require "rvm/capistrano"

set :application, "expo"
set :repository,  "git@github.com:uwexpd/expo.git"

set :scm, :git
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

default_run_options[:pty] = true
set :deploy_via, :remote_cache

set :user, "joshlin"
set :runner, "root"
set :use_sudo, true
set :deploy_to, "/usr/local/apps/#{application}"

server "expo.uaa.washington.edu", :app, :web, :db, :primary => true
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
    run "ln -nfs #{shared_path}/config/certs #{release_path}/config/certs"
    run "ln -nfs #{shared_path}/files #{release_path}/files"
    run "ln -nfs #{shared_path}/shared/images #{release_path}/public/images/shared"
    run "ln -nfs #{current_release}/public #{current_release}/public/expo"  
  end  
end

after "deploy:config_symlink"

# Using hoptoad_notifier
Dir[File.join(File.dirname(__FILE__), '..', 'vendor', 'gems', 'hoptoad_notifier-*')].each do |vendored_notifier|
  $: << File.join(vendored_notifier, 'lib')
end

require 'hoptoad_notifier/capistrano'
