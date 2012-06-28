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
set :branch, "master"
set :deploy_via, :remote_cache

set :user, "joshlin"
#set :runner, "root"
set :use_sudo, false
set :deploy_to, "/usr/local/apps/#{application}"

server "expo.uaa.washington.edu", :app, :web, :db, :primary => true
#role :web, "expo.uaa.washington.edu"                          # Your HTTP server, Apache/etc
#role :app, "expo.uaa.washington.edu"                          # This may be the same as your `Web` server
#role :db,  "expo.uaa.washington.edu", :primary => true        # This is where Rails migrations will run

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

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
  #   task :start do ; end
  #   task :stop do ; end
  #   task :restart, :roles => :app, :except => { :no_release => true } do
  #     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  #   end
end