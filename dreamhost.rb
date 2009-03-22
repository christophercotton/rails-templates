@using_git = true
domain_default = "cdwarren@designfigure.com"
@dreamhost_domain = ask("What is your user@domain for Git? (Default is #{domain_default})")
@dreamhost_domain = domain_default if @dreamhost_domain.blank?

# Create git repo on Dreamhost
app_name = run("pwd").split("/").last.strip
run "ssh #{@dreamhost_domain} 'mkdir -p ~/git/#{app_name}.git && cd ~/git/#{app_name}.git && git --bare init'"
git :init
run "git remote add origin ssh://#{@dreamhost_domain}/~/git/#{app_name}.git"

# Update .git-ignore
run "touch tmp/.gitignore log/.gitignore vendor/.gitignore"
  run %{find . -type d -empty | grep -v "vendor" | grep -v ".git" | grep -v "tmp" | xargs -I xxx touch xxx/.gitignore}
  file '.gitignore', <<-END
.DS_Store
log/*.log
tmp/**/*
config/database.yml
db/*.sqlite3
db/*.db
db/schema.rb
END

run "touch tmp/.gitignore log/.gitignore vendor/.gitignore"  
run "cp config/database.yml config/database.yml.example"

# Add to Git Repo
git :add => "."
git :commit => "-a -m 'Initial commit'"

# Based on http://casperfabricius.com/site/2008/09/21/keeping-git-repositories-on-dreamhost-using-ssh/