require 'sinatra'
require 'haml'
require 'pry-byebug' unless ENV['RACK_ENV'].match 'production'
require './lib/mashable'

class Reader < Sinatra::Base
  RETRIEVE_EVERY = 40 # every 120 seconds we're eligible to hit the api

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

  def initialize
    puts 'init is getting' if @all_stories.nil?
    @all_stories ||= sort_by_upvotes(get_stories)
    @stories_retrieved_at ||= Time.now
    super
  end

  # retrieves all stories if needed and saves it as @all_stories
  # sets @stories_retrieved_at
  def get_stories
    puts "ttr=#{time_to_reget?} if=#{self.object_id} @all_stories=[#{@all_stories}]"[0..100]
    if time_to_reget? || @all_stories.nil? || @all_stories.empty?
      @stories_retrieved_at = Time.now
      @all_stories = Mashable.get_mashable_stories
      # Sinatra is changing our instance and breaking how we reset our data
      # todo: needs further investigation to do this the sinatra way
      # it seems likely that sinatra is keeping the data we initialized FOREVER
    end
      @all_stories
  end
  # scope an array of stories to those matching the query
  def find_matching_stories(query, stories=@all_stories)
    queries = query.split(' ')
    stories.select do |story|
      queries.any? do |query|
        # Array#select will keep any stories that return true here
        story[:title].match(query) ? true : false
      end
    end
  end

  # determines if its time to re-hit our news sources
  def time_to_reget?
    puts @stories_retrieved_at
    return true if @stories_retrieved_at.nil?
    Time.now - @stories_retrieved_at > RETRIEVE_EVERY ? true : false
  end

  def sort_by_upvotes(stories)
    stories.sort do |a,b|
      -1* (a[:upvotes] <=> b[:upvotes])
    end
  end
end
