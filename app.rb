require 'sinatra'
require 'haml'
require 'pry-byebug' unless ENV['RACK_ENV'].match 'production'


class Reader < Sinatra::Base

  set :public_folder, File.dirname(__FILE__) + '/public'

  get '/' do
    #query = params.to_a.join(' ').strip
    query = params['q']
    puts "query=[#{query}]"
    if query.nil? || query.empty?
      erb :index
    else
      stories = get_stories
      @stories = find_matching_stories(query, stories)
      erb :index
    end
  end

  def get_stories
    @stories ||= [
      { title: 'newsey news', category: 'news', upvotes: 2 },
      { title: 'clinton does something undemocratic again', category: 'politics', upvotes: 18 },
      { title: "astronomers discover yet another planet that's way too big and way too far away", category: 'science', upvotes: 12 },
      { title: "Famous celebrity caught doing something really dumb again", category: 'entertainment', upvotes: 0 }
    ]
    @stories
  end

  def find_matching_stories(query, stories=@stories)
    queries = query.split(' ')
    stories.select do |story|
      queries.any? do |query|
        puts story
        story[:title].match(query) ? true : false
      end
    end
  end
end
