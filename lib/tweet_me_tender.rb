# encoding: utf-8
require "twitter"

class TweetMeTender
  MARKER_FILE_FILE = File.expand_path("~/.tweetmetender")
  PAGE_SIZE   = 50

  def self.configure
    Twitter.configure do |config|
      config.consumer_key       = ENV.fetch "TWITTER_KEY"
      config.consumer_secret    = ENV.fetch "TWITTER_SECRET"
      config.oauth_token        = ENV.fetch "TWITTER_TOKEN"
      config.oauth_token_secret = ENV.fetch "TWITTER_TOKEN_SECRET"
    end
  end

  def self.unread_tweets
    configure
    client = Twitter::Client.new
    marker = 0
    tweets = client.home_timeline(query).reverse.map do |tweet| 
      marker = tweet.id
      format(tweet)
    end
    save_marker marker
    tweets
  end

  def self.query
    marker ? { since_id: marker } : { count: PAGE_SIZE }
  end

  def self.format(tweet)
    formatted_tweet = "#{tweet.user.name} - #{tweet.user.screen_name} - "
    formatted_tweet << "#{tweet.created_at}\n\n"
    formatted_tweet << "#{tweet.text}\n\n"
    formatted_tweet << separator
    formatted_tweet
  end

  def self.separator
    "#{"-" * terminal_width}\n\n"
  end

  def self.marker
    begin
      File.open(MARKER_FILE_FILE, "r") { |f| f.gets.chomp.to_i }
    rescue
      false
    end
  end

  def self.save_marker(id)
    begin
      File.open(MARKER_FILE_FILE, "w") { |f| f.puts id }
      true
    rescue
      false
    end
  end

  private

  def self.terminal_width
    `tput cols`.to_i - 1
  end
end # TweetMeTender
