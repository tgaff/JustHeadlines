require "spec_helper"
require './config/environment'

RSpec.describe Reader do

  def app
    #Reader
    Reader.new!
  end

  let(:stories) {
    [
      { title: 'newsey news', category: 'news', upvotes: 2 },
      { title: 'clinton does something undemocratic again', category: 'politics', upvotes: 18 },
      { title: "astronomers discover yet another planet that's way too big and way too far away", category: 'science', upvotes: 12 },
      { title: "Famous celebrity caught doing something really dumb again", category: 'entertainment', upvotes: 0 }
    ]
  }

  describe "GET /" do
    it 'displays index.erb' do
      get "/"
      expect(last_response.body).to match(/indexificator/)
      expect(last_response.status).to eq 200
    end

    context "with a query" do
      before do
        allow(app).to receive(:get_stories).and_return(stories)
      end
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
      context "no matching results" do
        it "displays no results and tells the user" do
          get "/?q=alkdsjfldsjflksjdflksjflksj"
          expect(last_response).to match("Sorry")
          expect(last_response).to_not match('clinton')
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
    end
  end
end

