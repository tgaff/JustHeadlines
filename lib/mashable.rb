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
require 'csv'

module MashableAPI
  MASHABLE_URI = "http://mashable.com/stories.json"
  # Get request to a URL and parsed into JSON

  def get_mashable_stories
    mashable_json_response = connect_to_api(MASHABLE_URI)

    new_stories = parse_json(mashable_json_response, "new")
    rising_stories = parse_json(mashable_json_response, "rising")
    hot_stories = parse_json(mashable_json_response, "hot")
    [].push(new_stories, rising_stories, hot_stories).flatten
  end



  def connect_to_api(url)
    puts "hitting #{url}"
    get_data = RestClient.get(url)
    JSON.parse(get_data)
  end

  # Parses Mashable JSON to pull out story's title, category, upvotes returned in a new array for either new, rising, or hot stories
  def parse_json(json, type)
    story_array = []

    # Determine which hash in Mashable's JSON response to parse depending on parameter
    case type
    when "new"
      story_array = story_to_hash(json["new"])
    when "rising"
      story_array = story_to_hash(json["rising"])
    when "hot"
      story_array = story_to_hash(json["hot"])
    end

    return story_array
  end

  # Converts an array pulled from the JSON response into an array of hashes with keys: title, category, upvotes
  def story_to_hash(arr)
    story_array = []
    # Loop through the array of hashes to extract specific key-value pairs into a new hash
    arr.each do |story|
      story_hash = {
        title: story["title"],
        category: story["channel_label"],
        upvotes: story["shares"]["total"],
        link: story["link"]
      }
      # Push new hash into a new array
      story_array.push(story_hash)
    end

    return story_array
  end

  # Loop through an array of hashes and prints out a numbered, formatted list
  def print_stories(arr)
    count = 1
    arr.each do |story|
      puts "#{count}. [#{story[:category]}] #{story[:title]} (+#{story[:upvotes]})\n"
      count += 1
    end
  end
end
