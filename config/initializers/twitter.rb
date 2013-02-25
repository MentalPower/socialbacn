Twitter.configure do |config|
  if ENV['TWITTER_KEY'].nil? || ENV['TWITTER_KEY'].empty?
    raise ArgumentError.new("Required Twitter variable TWITTER_KEY missing")
  elsif ENV['TWITTER_SECRET'].nil? || ENV['TWITTER_SECRET'].empty?
    raise ArgumentError.new("Required Twitter variable TWITTER_SECRET missing")
  end

  config.consumer_key = ENV['TWITTER_KEY']
  config.consumer_secret = ENV['TWITTER_SECRET']
end
