plugin 'haml', :git => "git://github.com/nex3/haml.git"
run 'mkdir -p public/stylesheets/sass'
file "public/stylesheets/sass/base.sass"
file 'app/views/layouts/application.html.haml'

file 'app/views/public/index.html.haml'
file 'app/views/public/about.html.haml'
file 'app/views/public/contact.html.haml'

run "rm app/views/public/index.html.erb"
run "rm app/views/public/about.html.erb"
run "rm app/views/public/contact.html.erb"

if @using_git
  git :add => "."
  git :commit => "-a -m 'Set up Haml and Sass'"
end