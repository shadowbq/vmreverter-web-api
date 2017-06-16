class WebApi < Sinatra::Base

  register Sinatra::ConfigFile
  register Sinatra::RespondWith
  register Sinatra::Namespace
  register Sinatra::Initializers
  register Sinatra::StrongParams

  helpers Sinatra::Param

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
    content_type :json
    return basic_message "Hello World!"
  end

  get '/revert/:id', allows: [:id] do
    param :id, Integer, transform: :to_s, required: true

    content_type :json
    return connect_to_reverter(params['id'])
  end

  get '/test' do
    content_type :json
    return test_connect_to_reverter
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

  def connect_to_reverter(id)
    return badrequest "plan #{id} not found on server." unless Pathname.new("./config/plans/_#{id}.conf").exist?

    fork do
      @options = {:auth=>"./config/auth.secret", :config=>"./config/plans/_#{id}.conf", :options_file=>nil, :lockfile=>settings.lockfile, :quiet=>true, :color=>false, :debug=>false}
      @logger = Vmreverter::Logger.new
      @logger.add_destination('/var/log/vmreverter.log', 'a')
      @logger.remove_destination(STDOUT)
      Vmreverter::Configuration.build(@options, @logger)
      begin
        Vmreverter::VMManager.execute!(Vmreverter::Configuration.instance)
      rescue
      end
    end
    basic_message "running configuration #{id}"
  end

  def test_connect_to_reverter
    fork do
      @options = {:auth=>"./test/tmp/.fog", :config=>"./test/tmp/test.conf", :options_file=>nil, :lockfile=>"/var/lock/test.lock", :quiet=>true, :color=>false, :debug=>false}
      @logger = Vmreverter::Logger.new
      @logger.add_destination('/var/log/vmreverter.log', 'a')
      @logger.remove_destination(STDOUT)
      Vmreverter::Configuration.build(@options, @logger)
      begin
        Vmreverter::VMManager.execute!(Vmreverter::Configuration.instance)
      rescue
      end
    end
    basic_message "running test.conf"
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
