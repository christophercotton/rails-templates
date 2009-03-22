# Set up the dreamhost git repo
if yes?("Use Git on Dreamhost?")
  load_template "/Users/christopherdwarren/Workspace/rails-templates/dreamhost.rb"
  using_git = true
end

app_name = run("pwd").split("/").last.strip

# Set up gems
gem 'mislav-will_paginate', :lib => 'will_paginate', :source => 'http://gems.github.com'
gem 'RedCloth', :lib => 'redcloth'

# Install gems
rake("gems:install")

# Set up plugins
plugin 'exception_notifier', :git => 'git://github.com/rails/exception_notification.git'
plugin 'restful-authentication', :git => 'git://github.com/technoweenie/restful-authentication.git'

# Freeze Gems
rake("rails:freeze:gems") if yes?("Freeze rails gems?")

# Commit to git if we created the repo
if using_git
  git :add => "."
  git :commit => "-a -m 'Installed plugins and gems'"
  git :push => "origin master"
  
  if yes?("Set up Capistrano?")
    load_template "/Users/christopherdwarren/Workspace/rails-templates/capistrano.rb"
    
    git :add => "."
    git :commit => "-a -m 'Set up Capistrano'"
    git :push => "origin master"
    
    puts "-----------Don't forget to add your Git password to config/deploy.rb!-----------"
  end
end