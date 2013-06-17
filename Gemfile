source 'https://rubygems.org'

gem 'rails', '3.2.8'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'devise'
gem 'devise-i18n-views'
gem 'cancan'
gem 'activeadmin'

gem 'will_paginate', '~> 3.0.0'

gem 'simple_form'

gem 'rails_config'

gem "therubyracer"
gem "less-rails" #Sprockets (what Rails 3.1 uses for its asset pipeline) supports LESS
gem "twitter-bootstrap-rails"

gem 'pairtree'


# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'
# Gemfile
# for CRuby, Rubinius, including Windows and RubyInstaller
group :development, :test do
  gem "sqlite3", :platform => [:ruby, :mswin, :mingw]
  # JRuby
  gem "jdbc-sqlite3", :platform => :jruby
  gem "activerecord-jdbcsqlite3-adapter", :platform => :jruby
end

group :production do
  # Requires postgresql and pq-dev packages
  gem 'pg'
end

# Gems for test group
group :test do
  gem 'rake'
  gem 'cucumber-rails', :require => false
  gem 'database_cleaner'
end



# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'

end

gem 'jquery-rails'

gem 'prawn_rails'
gem 'uuid'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'debugger'
