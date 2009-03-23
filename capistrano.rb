run "gem install capistrano"
url = ask("What is your application's URL? (mydomain.com)")
git_pwd = ask("What is git user's password?")

gem 'capistrano'
run 'capify .'
run 'rm config/deploy.rb'
file "config/deploy.rb", <<-CAP
set :user, '#{@app_name}'  # Your dreamhost account's username
set :domain, 'foothill.dreamhost.com'  # Dreamhost servername where your account is located 
set :project, '#{@app_name}'  # Your application as its called in the repository
set :application, '#{url}'  # Your app's location (domain or sub-domain name as setup in panel)
set :applicationdir, "/home/#{@app_name}/#{url}"  # The standard Dreamhost setup

# version control config
default_run_options[:pty] = true
set :repository,  "ssh://#{@dreamhost_domain}/~/git/#{@app_name}.git"
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

desc "tail production log files" 
task :tail_logs, :roles => :app do
  run "tail -f \#{shared_path}/log/production.log" do |channel, stream, data|
    puts  # for an extra line break before the host name
    puts "\#{channel[:host]}: \#{data}" 
    break if stream == :err    
  end
end

desc "check production log files in textmate" 
task :mate_logs, :roles => :app do

  require 'tempfile'
  tmp = Tempfile.open('w')
  logs = Hash.new { |h,k| h[k] = '' }

  run "tail -n500 \#{shared_path}/log/production.log" do |channel, stream, data|
    logs[channel[:host]] << data
    break if stream == :err
  end

  logs.each do |host, log|
    tmp.write("--- \#{host} ---\n\n")
    tmp.write(log + "\n")
  end

  exec "mate -w \#{tmp.path}" 
  tmp.close
end

desc "remotely run console" 
task :console, :roles => :app do
  input = ''
  run "cd \#{current_path} && ./script/console \#{ENV['RAILS_ENV']}" do |channel, stream, data|
    next if data.chomp == input.chomp || data.chomp == ''
    print data
    channel.send_data(input = $stdin.gets) if data =~ /^(>|\?)>/
  end
end
CAP

git :add => "."
git :commit => "-a -m 'Set up Capistrano'"