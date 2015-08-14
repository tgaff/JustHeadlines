require 'sinatra'
require 'haml'
require 'pry-byebug' unless ENV['RACK_ENV'].match 'production'
require './lib/mashable'

class Reader < Sinatra::Base

  # container for MashableAPI
  class Mashable
    extend MashableAPI
  end

  set :public_folder, File.dirname(__FILE__) + '/public'

  get '/' do
    #query = params.to_a.join(' ').strip
    query = params['q']
    if query.nil? || query.empty?
      erb :index
    else
      stories = get_stories
      # NOTE we resave this var once it's sorted which should make future sorts fast
      @stories = sort_by_upvotes(find_matching_stories(query, stories))
      erb :index
    end
  end

  def initialize
    @stories = get_stories
    super
  end
  def get_stories
    if @stories.nil? || @stories.empty?
      @stories = Mashable.get_mashable_stories
    end
    @stories
  end

  def find_matching_stories(query, stories=@stories)
    queries = query.split(' ')
    stories.select do |story|
      queries.any? do |query|
        story[:title].match(query) ? true : false
      end
    end
  end

  def sort_by_upvotes(stories)
    stories.sort do |a,b|
      -1* (a[:upvotes] <=> b[:upvotes])
    end
  end
end
