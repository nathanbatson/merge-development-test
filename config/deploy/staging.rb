################################################################################################################
# This deploy recipe will deploy a project from a Codaset repo to a Linode VPS server
#
# Assumptions:
#   * You are using Linode for hosting, but this would most likely work on any VPS, such as Slicehost
#   * Your deployment directory is located in /srv/www/
#   * This is a Rails project and will use the staging environment
#
#################################################################################################################
#
# Change this to the name of the project.  It should match the name of the Git repo.
# This will set the name of the project directory and become the subdomain
set :project, 'merge-development-test' 
set :github_user, "nathanbatson" # Your GitHub username
set :domain_name, "mergetraining.comicalconcept.com" # should be something like mydomain.com
set :user, 'nathanbatson' # Linode username
set :domain, '74.207.233.153' # Linode IP address

#### You shouldn't need to change anything below ########################################################
default_run_options[:pty] = true

set :repository,  "git@github.com:#{github_user}/#{project}.git" #GitHub clone URL
set :scm, "git"
set :scm_passphrase, "" # This is the passphrase for the ssh key on the server deployed to
set :branch, "master"
set :scm_verbose, true
set :applicationdir, "/srv/www/#{domain_name}"
set :keep_releases, 1

# Don't change this stuff, but you may want to set shared files at the end of the file ##################
# deploy config
set :deploy_to, applicationdir
set :deploy_via, :remote_cache
set :runner, "nathanbatson" 
 
# roles (servers)
role :app, domain
role :web, domain
role :db,  domain, :primary => true

namespace :deploy do
  desc "Restarting mod_rails with restart.txt"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end
  
  [:start, :stop].each do |t|
    desc "#{t} task is a no-op with mod_rails"
    task t, :roles => :app do ; end
  end
end

namespace :crontab do
  desc "Update the crontab based on config/schedule.rb"
  task :update, :roles => :app, :except => { :no_release => true } do
    run "crontab -r"
    run "cd #{current_path} && rake update_crontab RAILS_ENV=production"
  end
end

# additional settings
#default_run_options[:pty] = true  # Forgo errors when deploying from windows
#ssh_options[:keys] = %w(/Path/To/id_rsa)            # If you are using ssh_keys

set :use_sudo, false
 
# Optional tasks ##########################################################################################
# for use with shared files (e.g. config files)
after "deploy:update_code" do
  # run "ln -s #{shared_path}/print_files #{release_path}"
  # run "ln -s #{shared_path}/illustration #{release_path}/public"
  # run "ln -s #{shared_path}/ads #{release_path}/public"
end