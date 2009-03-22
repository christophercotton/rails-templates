app_name = run("pwd").split("/").last.strip

# Set up the dreamhost git repo
load_template "/Users/christopherdwarren/Workspace/rails-templates/dreamhost.rb" if yes?("Use Git on Dreamhost?")

# Remove default files
run "rm README"
run "rm public/index.html"
run "rm public/favicon.ico"
run "rm public/robots.txt"

# Create public controller
generate(:controller, "public", "index", "about", "contact")
route "map.root :controller => :public"

# Set up gems
gem 'mislav-will_paginate', :lib => 'will_paginate', :source => 'http://gems.github.com'
gem 'RedCloth', :lib => 'redcloth'
# Install gems
rake("gems:install")
# Freeze Gems
rake("rails:freeze:gems") if yes?("Freeze Rails gems?")

# Set up plugins
plugin 'exception_notifier', :git => 'git://github.com/rails/exception_notification.git'
plugin 'authlogic', :git => 'git://github.com/binarylogic/authlogic.git'
plugin 'paperclip', :git => 'git://github.com/thoughtbot/paperclip.git'
plugin 'asset_packager', :git => 'http://synthesis.sbecker.net/pages/asset_packager'

# Commit to git if we created the repo
git :add => "." if @using_git
git :commit => "-a -m 'Installed plugins and gems'" if @using_git

if @using_git
  load_template "/Users/christopherdwarren/Workspace/rails-templates/capistrano.rb" if yes?("Set up Capistrano?")
end

load_template "/Users/christopherdwarren/Workspace/rails-templates/haml.rb" if yes?("Use Haml?")

git :push => "origin master" if @using_git