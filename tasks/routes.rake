require './app.rb'
include Rake::DSL

namespace :routes do
  task :show do
    WebApi.routes.each do |verb,handlers|
      puts "\n#{verb}:\n"
      handlers.each do |handler|
        puts handler[0].source.to_s
      end
    end
  end

  task :default => 'show'
end
