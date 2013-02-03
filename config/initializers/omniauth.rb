OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
  #Make sure our required environment variables are present.
  if ENV['TWITTER_KEY'].nil? || ENV['TWITTER_KEY'].empty?
    raise ArgumentError.new("Required Twitter variable TWITTER_KEY missing")
  elsif ENV['TWITTER_SECRET'].nil? || ENV['TWITTER_SECRET'].empty?
    raise ArgumentError.new("Required Twitter variable TWITTER_SECRET missing")
  end

  provider :twitter, ENV['TWITTER_KEY'], ENV['TWITTER_SECRET']
end
