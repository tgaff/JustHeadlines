require 'sinatra'
require 'haml'
require 'pry-byebug' unless ENV['RACK_ENV'].match 'production'


class Reader < Sinatra::Base

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
    @stories ||= [
      { title: 'newsey news', category: 'news', upvotes: 2 },
      { title: 'popular news', category: 'news', upvotes: 1000 },
      { title: "Famous celebrity caught doing something really dumb again", category: 'entertainment', upvotes: 0 },
      { title: 'clinton does something undemocratic again', category: 'politics', upvotes: 18 },
      { title: "astronomers discover yet another planet that's too big and far away", category: 'science', upvotes: 12 },
    ]
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
