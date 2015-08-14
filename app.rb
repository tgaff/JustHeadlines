require 'sinatra'
require 'haml'
require 'pry-byebug' unless ENV['RACK_ENV'].match 'production'
require './lib/mashable'
require './lib/reddit'

class Reader < Sinatra::Base

  # container for MashableAPI
  class Mashable
    extend MashableAPI
  end
  class Reddit
    extend RedditAPI
  end

  set :public_folder, File.dirname(__FILE__) + '/public'

  get '/' do
    #query = params.to_a.join(' ').strip
    query = params['q']
    if query.nil? || query.empty?
      erb :index
    else
      @stories = sort_by_upvotes(find_matching_stories(query, get_stories))
      erb :index
    end
  end

  # retrieves all stories if needed and saves it as @all_stories
  def get_stories
    @stories = Mashable.get_stories
    @stories.push(*Reddit.get_stories)
  end

  # scope an array of stories to those matching the query
  def find_matching_stories(query, stories=@stories)
    queries = query.downcase.split(' ') # downcase all for case-insensitive match
    stories.select do |story|
      queries.any? do |query|
        story[:title].downcase.match(query) ? true : false
      end
    end
  end

  def sort_by_upvotes(stories)
    stories.sort do |a,b|
      -1* (a[:upvotes] <=> b[:upvotes])
    end
  end
end
