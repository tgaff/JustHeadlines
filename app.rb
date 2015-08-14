require 'sinatra'
require 'haml'
require 'pry-byebug' unless ENV['RACK_ENV'].match 'production'
require './lib/mashable'

class Reader < Sinatra::Base
  RETRIEVE_EVERY = 120 # every 120 seconds we're eligible to hit the api

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
      @stories = sort_by_upvotes(find_matching_stories(query, stories))
      erb :index
    end
  end

  def get_stories
    if time_to_reget? || @stories.nil? || @stories.empty?
      @stories = Mashable.get_mashable_stories
    else
      @stories
    end
  end

  def find_matching_stories(query, stories=@stories)
    queries = query.split(' ')
    stories.select do |story|
      queries.any? do |query|
        story[:title].match(query) ? true : false
      end
    end
  end

  def time_to_reget?
    return true if @stories_retrieved_at.nil?
    @stories_retrieved_at < Time.now - RETRIEVE_EVERY ? true : false
  end
  def sort_by_upvotes(stories)
    stories.sort do |a,b|
      -1* (a[:upvotes] <=> b[:upvotes])
    end
  end
end
