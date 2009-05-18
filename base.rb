@app_name = @root.split("/").last.strip
@base_path = "/Users/christopherdwarren/Workspace/rails-templates"
# @base_path = "http://github.com/chriswarren/rails-templates.git"

# Set up the dreamhost git repo
load_template "#{@base_path}/dreamhost.rb" if yes?("Use Git on Dreamhost?")

# Remove default files
run "rm README"
run "rm public/index.html"
run "rm public/favicon.ico"
run "rm public/robots.txt"

# Create public controller
generate(:controller, "public", "index", "about", "contact")
route "map.root    :controller => 'public'"
route "map.about   'about', :controller => 'public', :action => 'about'"
route "map.contact 'contact', :controller => 'public', :action => 'contact'"

# Set up gems
load_template "#{@base_path}/gems.rb"

# Set up plugins
load_template "#{@base_path}/plugins.rb"

# Commit to git
git :add => "." if @using_git
git :commit => "-a -m 'Installed plugins and gems'" if @using_git

# Create the database
rake("db:create")

if @using_git
  load_template "#{@base_path}/capistrano.rb" if yes?("Set up Capistrano?")
end

load_template "#{@base_path}/haml.rb" if yes?("Use Haml?")

git :push => "origin master" if @using_git