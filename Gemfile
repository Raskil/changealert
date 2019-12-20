source ENV['GEM_SOURCE'] || "https://rubygems.org"

group :development, :test do
  gem 'rake',                           :require => false
  gem 'rspec-puppet',                   :require => false
  gem 'puppetlabs_spec_helper',         :require => false
  gem 'serverspec',                     :require => false
  gem 'puppet-lint',                    :require => false
#  gem 'beaker',                         :require => false
#  gem 'beaker-rspec',                   :require => false
  gem 'pry',                            :require => false
  gem 'simplecov',                      :require => false
  gem 'rubocop', '= 0.49.1',             :require => false
  gem 'rubocop-rspec', '= 1.15.1',       :require => false
  gem 'puppet-blacksmith', '>= 4.0.1',   :require => false
end

gem 'mail'
gem 'puppet-strings'

if facterversion = ENV['FACTER_GEM_VERSION']
  gem 'facter', facterversion, :require => false
else
  gem 'facter', :require => false
end

if puppetversion = ENV['PUPPET_GEM_VERSION']
  gem 'puppet', puppetversion, :require => false
else
  gem 'puppet', :require => false
end

