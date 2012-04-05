require 'mongrel_cluster/recipes'
set :application, "expo"
set :repository,  "svn+ssh://isidore/usr/local/svn/exporepo/trunk"
set :deploy_to, "/usr/local/apps/#{application}"
set :user, "joshlin"
#set :deploy_via, :export  # export from svn instead of checkout
set :deploy_via, :remote_cache
set :copy_exclude, [".svn", ".DS_Store"]

set :runner, "root"
default_run_options[:pty] = true
role :app, "isidore"
role :web, "isidore"
role :db,  "isidore", :primary => true

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


Dir[File.join(File.dirname(__FILE__), '..', 'vendor', 'gems', 'hoptoad_notifier-*')].each do |vendored_notifier|
  $: << File.join(vendored_notifier, 'lib')
end

require 'hoptoad_notifier/capistrano'
