require 'sinatra'
require 'haml'

set :public_folder, File.dirname(__FILE__) + '/public'

get '/' do
  query = params['query']
  if query.nil?
    erb :index
  else
    "not implemented"
  end

end
