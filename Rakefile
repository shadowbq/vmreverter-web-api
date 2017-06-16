require 'rspec/core'
require 'rspec/core/rake_task'
require 'rubygems'
require 'bundler'
require 'rake'
require 'bump/tasks'
require 'sinatra/strong-params'

Bundler.require

require 'sinatra'
require 'erb'
require 'rack/csrf'
require 'rack/protection'

require 'pry'

Bundler.setup

Dir["tasks/*.rake"].sort.each { |ext| load ext }

desc "Show available Routes"
task :routes => 'routes:default'

RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
  spec.rspec_opts = ['--backtrace']
  # spec.ruby_opts = ['-w']
end

task :default => :spec
