# encoding: utf-8
require "minitest/autorun"
require "ostruct"
require_relative "../lib/tweet_me_tender"

def delete_marker_file
  if File.exists?(TweetMeTender::MARKER_FILE_FILE)
    File.delete TweetMeTender::MARKER_FILE_FILE 
  end
end

def read_current_marker
  File.open(TweetMeTender::MARKER_FILE_FILE, "r") { |f| f.gets.chomp.to_i }
end

describe TweetMeTender do

  describe "#configure" do
    it "initializes authentication keys" do
      TweetMeTender.configure

      Twitter.consumer_key.must_equal       ENV.fetch("TWITTER_KEY")
      Twitter.consumer_secret.must_equal    ENV.fetch("TWITTER_SECRET")
      Twitter.oauth_token.must_equal        ENV.fetch("TWITTER_TOKEN")
      Twitter.oauth_token_secret.must_equal ENV.fetch("TWITTER_TOKEN_SECRET")
    end
  end

  describe "#unread_tweets" do
    it "returns a collection of unread tweets from the home timeline" do
    end
  end

  describe "#query" do
    it "returns a Hash with a :since_id key if marker present" do
      fake_marker_id = 123456789123456789
      File.open(TweetMeTender::MARKER_FILE_FILE, "w") do |f| 
        f.puts fake_marker_id
      end
      
      TweetMeTender.query.must_equal(since_id: fake_marker_id)
    end

    it "returns a Hash with a :count key if marker blank" do
      delete_marker_file
      TweetMeTender.query.must_equal(count: TweetMeTender::PAGE_SIZE)
    end
  end

  describe "#format" do
    it "formats a tweet for text display" do
      current_time = Time.now
      tweet = OpenStruct.new( 
        text:       "My cat had lasagna for lunch",
        created_at: current_time.to_s,
        user:       OpenStruct.new(name: "John Doe", screen_name: "@jdoe")
      )

      TweetMeTender.format(tweet).must_match %r{John Doe - @jdoe - .*\n.*}
      TweetMeTender.format(tweet).must_match %r{.*\nMy cat had lasagna for lunch\n.*}
      TweetMeTender.format(tweet).must_match %r{.*\n-----+\n.*}
    end
  end

  describe "#separator" do
    it "returns a string with as much dashes as the terminal width" do
      TweetMeTender.separator.must_match /--------\n\n/
    end
  end

  describe "#marker" do
    it "returns the id of the latest tweet read" do
      TweetMeTender.marker.must_be_instance_of Bignum
    end

    it "extracts the marker from the marker dotfile" do
      fake_marker_id = 123456789123456789
      File.open(TweetMeTender::MARKER_FILE_FILE, "w") do |f| 
        f.puts fake_marker_id
      end

      TweetMeTender.marker.must_equal fake_marker_id
    end

    it "returns false if marker dotfile doesn't exist" do
      delete_marker_file
      TweetMeTender.marker.must_equal false
    end
  end

  describe "#save_marker" do
    it "saves the id of the latest tweet read to the marker dotfile" do
      fake_marker_id = 12345678987654321
      TweetMeTender.save_marker(fake_marker_id)
      current_marker = read_current_marker

      current_marker.must_equal fake_marker_id

      fake_marker_id = 123456789123456789
      TweetMeTender.save_marker(fake_marker_id)
      current_marker = read_current_marker

      current_marker.must_equal fake_marker_id
    end
  end

end # TweetMeTender specs
