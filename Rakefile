require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'
require 'metadata-json-lint/rake_task'
require 'puppet_blacksmith/rake_tasks'
require 'puppet-strings/tasks'

Blacksmith::RakeTask.new do |t|
  t.tag_pattern = "v%s" # Use a custom pattern with git tag. %s is replaced with the version number.
  t.tag_message_pattern = "[Blacksmith] bump to version %s"
  t.build = false # do not build the module nor push it to the Forge, just do the tagging [:clean, :tag, :bump_commit]
end

Rake::Task['module:push'].clear
task 'module:push' do
  Rake::Task['spec'].invoke
end


if RUBY_VERSION >= '1.9'
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new
end

PuppetLint.configuration.send('disable_80chars')
PuppetLint.configuration.relative = true
PuppetLint.configuration.ignore_paths = ['spec/**/*.pp', 'pkg/**/*.pp']
PuppetLint.configuration.send('disable_relative_classname_inclusion')

desc 'Validate manifests, templates, and ruby files'
task :validate do
  Dir['manifests/**/*.pp'].each do |manifest|
    sh "puppet parser validate --noop #{manifest}"
  end
  Dir['spec/**/*.rb', 'lib/**/*.rb'].each do |ruby_file|
    sh "ruby -c #{ruby_file}" unless ruby_file =~ %r{spec/fixtures}
  end
  Dir['templates/**/*.erb'].each do |template|
    sh "erb -P -x -T '-' #{template} | ruby -c"
  end
end

desc 'Run lint, validate, and spec tests.'
task :test do
  [:lint, :validate, :spec].each do |test|
    Rake::Task[test].invoke
  end
end
