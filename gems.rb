gem 'mislav-will_paginate', :lib => 'will_paginate', :source => 'http://gems.github.com'
gem 'RedCloth', :lib => 'redcloth'
gem 'thoughtbot-shoulda', :source => "http://gems.github.com"

# Install gems
rake("gems:install")
# Freeze Gems
rake("rails:freeze:gems") if yes?("Freeze Rails gems?")