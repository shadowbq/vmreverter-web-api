$LOAD_PATH << '.'

require 'rubygems'
require 'bundler'

Bundler.require

require 'sinatra'
require 'sinatra/config_file'
require 'sinatra/namespace'
require 'sinatra/respond_with'
require 'sinatra/param'
require 'sinatra/strong-params'

require 'rack/csrf'
require 'rack/protection'
require 'rack-flash'

Bundler.require(:default, ENV['RACK_ENV'].to_sym)  # only loads environment specific gems
if ENV['RACK_ENV'] == 'production'           # production config / requires
  true
else
  require 'pry'
  require 'pry-byebug'
  use Rack::ShowExceptions
end

require 'sinatra-initializers'

use Rack::Alpaca

use Rack::Session::Cookie, :secret => 'WhatisTh1sMyS3cr3t!'

use Rack::Csrf, :raise => true
use Rack::Protection
use Rack::Flash


require 'app'

run WebApi
