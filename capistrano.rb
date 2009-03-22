run "gem install capistrano"
app_name = run("pwd").split("/").last.strip
url = ask("What is your application's URL? (mydomain.com)")
git_pwd = ask("What is git user's password?")

gem 'capistrano'
run 'capify .'
run 'rm config/deploy.rb'
file "config/deploy.rb", <<-CAP
set :user, '#{app_name}'  # Your dreamhost account's username
set :domain, 'foothill.dreamhost.com'  # Dreamhost servername where your account is located 
set :project, '#{app_name}'  # Your application as its called in the repository
set :application, '#{url}'  # Your app's location (domain or sub-domain name as setup in panel)
set :applicationdir, "/home/#{app_name}/#{url}"  # The standard Dreamhost setup

# version control config
default_run_options[:pty] = true
set :repository,  "ssh://#{@dreamhost_domain}/~/git/#{app_name}.git"
set :scm, "git"
set :scm_passphrase, "#{git_pwd}" # Your Git user's password

set :branch, "master"

# roles (servers)
role :web, domain
role :app, domain
role :db,  domain, :primary => true

# deploy config
set :deploy_to, applicationdir
set :deploy_via, :export

# additional settings
#ssh_options[:keys] = %w(/Path/To/id_rsa)            # If you are using ssh_keys
set :chmod755, "app config db lib public vendor script script/* public/disp* tmp/cache"
set :use_sudo, false

namespace :deploy do
  desc "Restarting mod_rails with restart.txt"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch \#{current_path}/tmp/restart.txt"
    FileUtils.rm_rf(Dir.glob(RAILS_ROOT+"/tmp/cache/views/*")) rescue Errno::ENOENT
  end

  [:start, :stop].each do |t|
    desc "\#{t} task is a no-op with mod_rails"
    task t, :roles => :app do ; end
  end
end

namespace :git do
  task :unpushed do
    ahead = `git log origin/\#{branch}..\#{branch} --pretty=oneline --abbrev-commit`
    unless ahead == ""
      puts "Whoa, hoss. Looks like you forgot to push the following SHAs:"
      puts ahead
      print "Continue with the deploy anyway? [y/N] "
      if $stdin.gets.chomp.upcase != "Y"
        puts "Good call. `git push` and come back."
        exit
      end
    end
  end
end
before "deploy:update_code", "git:unpushed"
CAP

git :add => "."
git :commit => "-a -m 'Set up Capistrano'"