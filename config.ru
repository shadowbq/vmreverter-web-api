$LOAD_PATH << '.'

require 'rubygems'
require 'bundler'

Bundler.require

require 'sinatra'
require 'rack/csrf'

require 'rack/protection'
require 'bcrypt'

require 'rack-flash'

require 'pry'
require 'sinatra-initializers'

use Rack::Alpaca

use Rack::ShowExceptions
use Rack::Session::Cookie, :secret => "WhatisTh1sMyS3cr3t!"

use Rack::Csrf, :raise => true
use Rack::Protection
use Rack::Flash


require 'app'

run WebApi
