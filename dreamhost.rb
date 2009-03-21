#  Change this to your_account@your_domain
dreamhost_domain = 'cdwarren@designfigure.com'

# Create git repo on Dreamhost
app_name = run("pwd").split("/").last.strip
run "ssh #{dreamgit_domain} 'mkdir -p ~/git/#{app_name}.git && cd ~/git/#{app_name}.git && git --bare init'"
git :init
run "git remote add origin ssh://#{dreamgit_domain}/~/git/#{app_name}.git"

# Remove default files
run "rm README"
run "rm public/index.html"
run "rm public/favicon.ico"
run "rm public/robots.txt"

# Update .git-ignore
run "touch tmp/.gitignore log/.gitignore vendor/.gitignore"
  run %{find . -type d -empty | grep -v "vendor" | grep -v ".git" | grep -v "tmp" | xargs -I xxx touch xxx/.gitignore}
  file '.gitignore', <<-END
.DS_Store
log/*.log
tmp/**/*
config/database.yml
db/*.sqlite3
END

run "touch tmp/.gitignore log/.gitignore vendor/.gitignore"  
run "cp config/database.yml config/example_database.yml"

# Add to Git Repo
git :add => "."
git :commit => "-a -m 'Initial commit'"
git :push => "origin master"

# Based on http://casperfabricius.com/site/2008/09/21/keeping-git-repositories-on-dreamhost-using-ssh/