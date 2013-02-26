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

  def update_tweets
    update_home_timeline
    update_user_timeline
  end

  def update_home_timeline
    if twitter
      begin
        #Get the most recent tweetID
        since_id = self.newest_home_tweet || 1
        puts("update_home_init", since_id)

        #Then get all the tweets since that ID
        home_timeline = twitter.home_timeline(:count => 200, :since_id => since_id)
        num_tweets, min_tweet, max_tweet = Tweet.bulk_insert(home_timeline)
        puts("update_home_first", num_tweets, min_tweet, max_tweet)

        #Save this out since scoping rules make it needed below
        global_max_tweet = [since_id, max_tweet || 1].max

        #If we've never seen this user before, get all the tweets we can.
        if since_id == 1
          loop do
            home_timeline = twitter.home_timeline(:count => 200, :max_id => min_tweet)
            num_tweets, min_tweet, max_tweet = Tweet.bulk_insert(home_timeline)
            puts("update_home_new", num_tweets, min_tweet, max_tweet)
            global_max_tweet = [max_tweet || 1, global_max_tweet || 1].max
            puts(global_max_tweet)
            #raise
            break if num_tweets <= 1
          end

          #Save our position for the next run
          self.newest_home_tweet = global_max_tweet
          self.save!

        #If this is a refresh, and we get more than one tweet, get any tweets that we haven't seen yet
        elsif num_tweets > 1
          loop do
            home_timeline = twitter.home_timeline(:count => 200, :since_id => max_tweet)
            num_tweets, min_tweet, max_tweet = Tweet.bulk_insert(home_timeline)
            puts("update_home_refresh", num_tweets, min_tweet, max_tweet)
            global_max_tweet = [max_tweet || 1, global_max_tweet || 1].max
            puts(global_max_tweet)
            #raise
            break if num_tweets <= 1
          end
        end

        #Update our position at the end
        puts("update_home_update", global_max_tweet)
        self.newest_home_tweet = global_max_tweet
        self.save!

      #Very common to run into rate limits unintentionally, lets make sure the app doesn't die
      rescue Twitter::Error::TooManyRequests => error
        puts(
          "update_home_TooManyRequests",
          "x-rate-limit-limit: " + error.rate_limit.limit.to_s,
          "x-rate-limit-remaining: " + error.rate_limit.remaining.to_s,
          "x-rate-limit-reset: " + time_ago_in_words(error.rate_limit.reset_at, true) + " (" + error.rate_limit.reset_at.to_s + ")"
        )
      end
    end
  end

  def update_user_timeline
    if twitter
      begin
        #Get the most recent tweetID
        since_id = self.newest_user_tweet || 1
        puts("update_user_init", since_id)

        #Then get all the tweets since that ID
        user_timeline = twitter.user_timeline(:count => 200, :since_id => since_id)
        num_tweets, min_tweet, max_tweet = Tweet.bulk_insert(user_timeline)
        puts("update_user_first", num_tweets, min_tweet, max_tweet)

        #Save this out since scoping rules make it needed below
        global_max_tweet = [since_id, max_tweet || 1].max

        #If we've never seen this user before, get all the tweets we can.
        if since_id == 1
          loop do
            user_timeline = twitter.user_timeline(:count => 200, :max_id => min_tweet)
            num_tweets, min_tweet, max_tweet = Tweet.bulk_insert(user_timeline)
            puts("update_user_new", num_tweets, min_tweet, max_tweet)
            global_max_tweet = [max_tweet || 1, global_max_tweet || 1].max
            puts(global_max_tweet)
            #raise
            break if num_tweets <= 1
          end

          #Save our position for the next run
          self.newest_user_tweet = global_max_tweet
          self.save!

        #If this is a refresh, and we get more than one tweet, get any tweets that we haven't seen yet
        elsif num_tweets > 1
          loop do
            user_timeline = twitter.user_timeline(:count => 200, :since_id => max_tweet)
            num_tweets, min_tweet, max_tweet = Tweet.bulk_insert(user_timeline)
            puts("update_user_refresh", num_tweets, min_tweet, max_tweet)
            global_max_tweet = [max_tweet || 1, global_max_tweet || 1].max
            puts(global_max_tweet)
            #raise
            break if num_tweets <= 1
          end
        end

        #Update our position at the end
        puts("update_user_update", global_max_tweet)
        self.newest_user_tweet = global_max_tweet
        self.save!

      #Very common to run into rate limits unintentionally, lets make sure the app doesn't die
      rescue Twitter::Error::TooManyRequests => error
        puts(
          "update_user_TooManyRequests",
          "x-rate-limit-limit: " + error.rate_limit.limit.to_s,
          "x-rate-limit-remaining: " + error.rate_limit.remaining.to_s,
          "x-rate-limit-reset: " + time_ago_in_words(error.rate_limit.reset_at, true) + " (" + error.rate_limit.reset_at.to_s + ")"
        )
      end
    end
  end
end
