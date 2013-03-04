class User < ActiveRecord::Base
  #We only use this for debugging, but we can't put it any closer to where its used.
  include ActionView::Helpers::DateHelper
  self.primary_key = 'twitter_uid'
  has_many :tweets

  def self.from_omniauth(auth)
    if auth.provider == "twitter"
      user = where(:twitter_uid => auth.uid).first || create_from_omniauth(auth)
      user.name = auth["info"]["nickname"]
      user.oauth_token = auth["credentials"]["token"]
      user.oauth_secret = auth["credentials"]["secret"]
      user.save!
      user
    end
  end

  def self.create_from_omniauth(auth)
    create! do |user|
      user.twitter_uid = auth["uid"]
      user.name = auth["info"]["nickname"]
      user.oauth_token = auth["credentials"]["token"]
      user.oauth_secret = auth["credentials"]["secret"]
    end
  end

  def self.create_from_twitter(twitter_user)
    create! do |user|
      user.twitter_uid = twitter_user.id
      user.name = twitter_user.screen_name
    end
  end

  def twitter
    if twitter_uid != nil && oauth_token != nil && oauth_secret != nil
      @twitter ||= Twitter::Client.new(oauth_token: oauth_token, oauth_token_secret: oauth_secret)
    end
  end

  def update_twitter
    if twitter
      num_tweets, min_tweet, max_tweet = update_timeline(self.newest_home_tweet, "home_timeline")
      self.newest_home_tweet = max_tweet
      self.save!

      num_tweets, min_tweet, max_tweet = update_timeline(self.newest_user_tweet, "user_timeline")
      self.newest_user_tweet = max_tweet
      self.save!
    end
  end

  def update_timeline(since_id = 1, timeline)
    begin
      #Get the most recent tweetID
      puts(timeline + "_init", since_id)

      #Then get all the tweets since that ID
      tweets = twitter.send(timeline, :count => 200, :since_id => since_id)
      num_tweets, min_tweet, max_tweet = Tweet.bulk_insert(tweets)
      puts(timeline + "_first", num_tweets, min_tweet, max_tweet)

      #Save this out since scoping rules make it needed below
      global_max_tweet = [since_id, max_tweet].compact.max
      global_min_tweet = [global_max_tweet, min_tweet].compact.min
      global_num_tweets = num_tweets || 0

      #If we've never seen this user before, get all the tweets we can.
      if since_id == 1
        loop do
          tweets = twitter.send(timeline, :count => 200, :max_id => global_min_tweet)
          num_tweets, min_tweet, max_tweet = Tweet.bulk_insert(tweets)
          puts(timeline + "_new", num_tweets, min_tweet, max_tweet)
          global_max_tweet = [max_tweet, global_max_tweet].compact.max
          global_min_tweet = [min_tweet, global_min_tweet, global_max_tweet].compact.min
          global_num_tweets += num_tweets
          #raise
          break if num_tweets <= 1
        end

      #If this is a refresh, and we get more than one tweet, get any tweets that we haven't seen yet
      elsif num_tweets > 1
        #Scan forwards
        loop do
          tweets = twitter.send(timeline, :count => 200, :since_id => global_max_tweet)
          num_tweets, min_tweet, max_tweet = Tweet.bulk_insert(tweets)
          puts(timeline + "_refresh_max", num_tweets, min_tweet, max_tweet)
          global_max_tweet = [max_tweet, global_max_tweet].compact.max
          global_min_tweet = [min_tweet, global_min_tweet, global_max_tweet].compact.min
          global_num_tweets += num_tweets
          #raise
          break if num_tweets <= 1
        end

        #And also scan backwards
        loop do
          tweets = twitter.send(timeline, :count => 200, :max_id => global_min_tweet)
          num_tweets, min_tweet, max_tweet = Tweet.bulk_insert(tweets)
          puts(timeline + "_refresh_min", num_tweets, min_tweet, max_tweet)
          global_max_tweet = [max_tweet, global_max_tweet].compact.max
          global_min_tweet = [min_tweet, global_min_tweet, global_max_tweet].compact.min
          global_num_tweets += num_tweets
          #raise
          break if num_tweets <= 1
        end
      end

      #Return our global counts
      puts(timeline + "_final", global_num_tweets, global_min_tweet, global_max_tweet)
      return global_num_tweets, global_min_tweet, global_max_tweet

    #Very common to run into rate limits unintentionally, lets make sure the app doesn't die
    rescue Twitter::Error::TooManyRequests => error
      puts(
        timeline + "_TooManyRequests",
        "limit: " + error.rate_limit.limit.to_s,
        "remaining: " + error.rate_limit.remaining.to_s,
        "reset: " + time_ago_in_words(error.rate_limit.reset_at, true) + " (" + error.rate_limit.reset_at.to_s + ")"
      )
    end
  end
end
