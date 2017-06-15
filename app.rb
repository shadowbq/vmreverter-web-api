class WebApi < Sinatra::Base

  register Sinatra::ConfigFile
  register Sinatra::RespondWith
  register Sinatra::Namespace
  register Sinatra::Initializers

  configure do
    config_file 'config/config.yml'
    set :method_override, true
    set :environment, :development
  end

  ## Hack to fix the extension to accept json params
  before /.*/ do
    if request.url.match(/.json$/)
    request.accept.unshift('application/json')
    request.path_info = request.path_info.gsub(/.json$/,'')
    end
  end

  get '/' do
    flash[:something] = "Something Else"
    haml :index
  end

  get '/test/syslog' do
    a = "hello, world!"
    puts shellex("logger sinatra[webapi] ?", a).stdout
  end
end

require_relative 'helpers/init'
