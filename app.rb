require 'sinatra'
require 'haml'



class Reader < Sinatra::Base

  set :public_folder, File.dirname(__FILE__) + '/public'

  get '/' do
    query = params['query']
    if query.nil?
      erb :index
    else
      "not implemented"
    end
  end
end
