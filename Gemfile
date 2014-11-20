source 'https://rubygems.org'
ruby '2.1.2'

gem 'bootstrap-sass', '~> 3.1.1.1'
gem 'coffee-rails'
gem 'rails', '4.1.5'
gem 'haml-rails'
gem 'sass-rails'
gem 'uglifier'
gem 'jquery-rails'
gem 'json'
gem 'bcrypt'
gem 'bootstrap_form'
gem 'faker'
gem 'fabrication'
gem 'figaro'
gem 'sidekiq'
gem 'unicorn'
gem 'paratrooper'

group :development do
  gem 'sqlite3'
  gem 'thin'
  gem "better_errors"
  gem "binding_of_caller"
  gem "letter_opener"
end

group :development, :test do
  gem 'pry'
  gem 'pry-nav'
  # ygurevich: 10/14/2014: experimenting with updating rspec-rails version to latest stable, from prior 2.99
  # ygurevich: 10/14/2014: reverting to spec 2.99
  gem 'rspec-rails', '2.99'
end

group :test do
  gem 'database_cleaner', '1.2.0'
  gem 'shoulda-matchers'
  gem 'capybara'
  gem 'capybara-email'
end

group :production do
  gem 'pg'
  gem 'rails_12factor'
  gem 'sentry-raven', :git => "https://github.com/getsentry/raven-ruby.git"
end

