app_name = run("pwd").split("/").last.strip
@using_git = true

@git_user = "gitless@expectless.com"
@git_path = "~/#{app_name}.git"
@ssh_git_path = "ssh://#{@git_user}/#{@git_path}"

# Create git repo on Dreamhost
run "ssh #{@git_user} 'mkdir -p #{@git_path} && cd #{@git_path} && git --bare init'"
git :init
run "git remote add origin #{@ssh_git_path}"

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