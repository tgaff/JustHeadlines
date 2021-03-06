require "spec_helper"
require './config/environment'

RSpec.describe Reader do

  let(:app) { Reader.new! } #deal with sinatra's weird new override
  let(:stories) {
    [
      { title: 'newsey news', category: 'news', upvotes: 2 },
      { title: 'popular news', category: 'news', upvotes: 1000 },
      { title: "Famous celebrity caught doing something really dumb again", category: 'entertainment', upvotes: 0 },
      { title: 'clinton does something undemocratic again', category: 'politics', upvotes: 18 },
      { title: "astronomers discover yet another planet that's too big and far away", category: 'science', upvotes: 12 },
    ]
  }
  before do
    allow(Reader::Mashable).to receive(:get_stories).and_return(stories)
    allow(Reader::Reddit).to receive(:get_stories).and_return([])
  end

  describe "GET /" do
    it 'displays index.erb' do
      get "/"
      expect(last_response.body).to match(/indexificator/)
      expect(last_response.status).to eq 200
    end
    context "without a query" do
      it 'returns all results' do
        get "/"
        expect(last_response).to match('clinton')
        expect(last_response).to match('newsey')
        expect(last_response).to match('astronomers')
        expect(last_response).to match('really dumb')
      end
    end

    context "with a query" do
      it 'returns 200' do
        get "/?q=dogfood"
        expect(last_response.status).to eq 200
      end
      it "returns the matching stories" do
        get "/?q=clinton"
        expect(last_response).to match("clinton does something")
      end
      it "doesn't return unrelated stories" do
        get "/?q=clinton"
        expect(last_response).to match("clinton")
        expect(last_response).to_not match(/astronomers/)
        expect(last_response).to_not match(/celebrity/)
      end
      it "sorts stories based on votes" do
        get "/?q=do"
        expect(last_response).to match(/clinton.*celebrity/m)
        get "/?q=news"
        expect(last_response).to match(/popular.*newsey/m)
      end

      context "no matching results" do
        it "displays no results and tells the user" do
          get "/?q=alkdsjfldsjflksjdflksjflksj"
          expect(last_response).to match("Sorry")
          expect(last_response).to_not match('clinton')
        end
      end
    end
  end

  describe '#find_matching_stories' do
    subject(:reader) { Reader.new! }
    let(:result) { reader.find_matching_stories('clinton', stories) }

    it 'returns an array of hashes' do
      expect(result).to be_a Array
      expect(result.first).to be_a Hash
      expect(result.last).to be_a Hash
    end
    it 'only returns matching results' do
      expect(result.length).to eq 1
    end
    it 'is case insensitive' do
      reader.find_matching_stories('CLiNtON', stories)
      expect(result.length).to eq 1
    end
  end
end

