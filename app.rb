class WebApi < Sinatra::Base

  register Sinatra::ConfigFile
  register Sinatra::RespondWith
  register Sinatra::Namespace
  register Sinatra::Initializers
  register Sinatra::StrongParams
  
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
    "Hello World!"
  end

  get '/test/syslog' do
    content_type :json
    a = "hello, world!"
    return basic_message(shellex("logger sinatra[webapi] ?", a).stdout)
  end

  get '/ping', allows: [] do
    content_type :json
    begin
      return {
        "date" => Time.now.utc,
      }.to_json
    rescue
      return internalerror 'there was a problem getting heartbeat'
    end
  end

  get '/*', allows: [] do
    return badrequest 'this request is not supported'
  end

  def basic_message msg
    {
      "data" => msg
    }.to_json
  end

  def error_message msg
    {
      "error" => msg
    }.to_json
  end

  def badrequest msg
    content_type :json
    [400, error_message(msg)]
  end

  def internalerror msg
   content_type :json
   [500, error_message(msg)]
  end

end

require_relative 'helpers/init'
