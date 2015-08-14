# borrowed from morgan

#1 - Pull the json from the reddit API via http://www.reddit.com/.json
  # - http://mashable.com/stories.json (homework)
  # - http://digg.com/api/news/popular.json (Homework)
#2 - Parse it using the JSON library
#3 - Find the stories based on techniques used in the code_along (max of 25 provided)
#4 - Create a new story hash out of each story with the following keys :title, :upvotes and :category
    #title, #category and #upvotes may not be the names use
#5 - Add each story to an array
#6 - Print each story from the array on your "Front Page"
#7 - BONUS ### create an 'csv' file using the api data & Ruby's CSV library
     # -> http://ruby-doc.org/stdlib-2.2.2/libdoc/csv/rdoc/CSV.html
         #title, upvote, category are the required columns

require 'rest-client'
require 'pry'
require 'json'

module RedditAPI

  REDDIT_URI = "http://www.reddit.com/.json"

  def get_stories
    reddit_json_responses = connect_to_api(REDDIT_URI)
    stories = find_stories(reddit_json_responses)
    prep_stories(stories)
  end


  def connect_to_api(url)
    puts "fetching reddit!"
    get_data = RestClient.get(url) #assume the output is from a Get request, so just need to pass in an endpoint
    JSON.parse(get_data)
  end

  def find_stories(get_data) # can call the argument anything, this is just good etiquette to pass the variable name from one method to another
    stories = get_data['data']['children'] #returns the top 25 stories in an Array
    puts "Reddit has blessed us with #{stories.length} stories"
    return stories
  end

  def prep_stories(stories)
    story_array = []
    stories.each do |story|
      story_array.push( create_story_hash(story) )
    end
    story_array
  end

  def create_story_hash(story)
    {title: story['data']['title'], category: story['data']['subreddit'], upvotes: story['data']['ups']}
  end


end
