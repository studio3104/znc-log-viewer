require 'uri'
require 'sinatra/base'
require 'sinatra/json'
require 'slim'

module ZNCLogViewer
  class Server < Sinatra::Base
    configure do
      Slim::Engine.default_options[:pretty] = true
      app_root = File.dirname(__FILE__) + '/../..'
      set :public_folder, app_root + '/public'
      set :views, app_root + '/views'
    end

    configure :development do
      require 'sinatra/reloader'
      register Sinatra::Reloader
      set :show_exception, false
      set :show_exception, :after_handler
    end

    not_found do
      '<b><font size="7">404</font></b>'
    end

    get '/' do
      slim :index
    end
  end
end
