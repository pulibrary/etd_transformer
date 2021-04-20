# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem 'coveralls', require: false
gem 'creek'
gem 'rake'
gem 'thor'
gem 'yard'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'bixby'
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'rspec', '~> 3.0'
end
