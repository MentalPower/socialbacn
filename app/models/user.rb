class User < ActiveRecord::Base
  #We only use this for debugging, but we can't put it any closer to where its used.
  include ActionView::Helpers::DateHelper
  has_many :tweets, :primary_key => :twitter_uid

  has_many :friendships
  has_many :friends, :through => :friendships

  has_many :inverse_friendships, :class_name => "Friendship", :foreign_key => "friend_id"
  has_many :inverse_friends, :through => :inverse_friendships, :source => :user

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

  def self.find_or_create_from_twitter(twitter_user)
    User.where(:twitter_uid => twitter_user.id).first || User.create_from_twitter(twitter_user)
  end

  def twitter
    if twitter_uid != nil && oauth_token != nil && oauth_secret != nil
      @twitter ||= Twitter::Client.new(oauth_token: oauth_token, oauth_token_secret: oauth_secret)
    end
  end

  def update_twitter
    if twitter
      update_friendships()

      num_new_tweets, num_old_tweets, min_tweet, max_tweet = update_timeline(self.newest_home_tweet, "home_timeline")
      self.newest_home_tweet = max_tweet
      self.save!

      num_new_tweets, num_old_tweets, min_tweet, max_tweet = update_timeline(self.newest_user_tweet, "user_timeline")
      self.newest_user_tweet = max_tweet
      self.save!
    end
  end

  def update_timeline(since_id = 1, timeline)
    begin
      #Get the most recent tweetID
      since_id = since_id || 1
      puts(timeline + "_init", since_id)

      #Then get all the tweets since that ID
      tweets = twitter.send(timeline, :count => 200, :since_id => since_id)
      num_new_tweets, num_old_tweets, min_tweet, max_tweet = Tweet.bulk_insert(tweets)
      puts(timeline + "_first", num_new_tweets, num_old_tweets, min_tweet, max_tweet)

      #Save this out since scoping rules make it needed below
      global_max_tweet = [since_id, max_tweet].compact.max
      global_min_tweet = [global_max_tweet, min_tweet].compact.min
      global_new_tweets = num_new_tweets || 0
      global_old_tweets = num_old_tweets || 0

      #If we've never seen this user before, get all the tweets we can.
      if since_id == 1
        loop do
          puts(timeline + "_new_init", global_min_tweet)
          tweets = twitter.send(timeline, :count => 200, :max_id => global_min_tweet)
          num_new_tweets, num_old_tweets, min_tweet, max_tweet = Tweet.bulk_insert(tweets)
          puts(timeline + "_new", num_new_tweets, num_old_tweets, min_tweet, max_tweet)
          global_max_tweet = [max_tweet, global_max_tweet].compact.max
          global_min_tweet = [min_tweet, global_min_tweet, global_max_tweet].compact.min
          global_new_tweets += num_new_tweets
          global_old_tweets += num_old_tweets
          #raise
          break if num_new_tweets <= 1
        end

      #If this is a refresh, and we get more than one tweet, get any tweets that we haven't seen yet
      elsif num_new_tweets > 1
        #Scan forwards
        loop do
          puts(timeline + "_refresh_max_init", global_max_tweet)
          tweets = twitter.send(timeline, :count => 200, :since_id => global_max_tweet)
          num_new_tweets, num_old_tweets, min_tweet, max_tweet = Tweet.bulk_insert(tweets)
          puts(timeline + "_refresh_max", num_new_tweets, num_old_tweets, min_tweet, max_tweet)
          global_max_tweet = [max_tweet, global_max_tweet].compact.max
          global_min_tweet = [min_tweet, global_min_tweet, global_max_tweet].compact.min
          global_new_tweets += num_new_tweets
          global_old_tweets += num_old_tweets
          #raise
          break if num_new_tweets <= 1
        end

        #And also scan backwards
        loop do
          puts(timeline + "_refresh_min_init", global_min_tweet)
          tweets = twitter.send(timeline, :count => 200, :max_id => global_min_tweet)
          num_new_tweets, num_old_tweets, min_tweet, max_tweet = Tweet.bulk_insert(tweets)
          puts(timeline + "_refresh_min", num_new_tweets, num_old_tweets, min_tweet, max_tweet)
          global_max_tweet = [max_tweet, global_max_tweet].compact.max
          global_min_tweet = [min_tweet, global_min_tweet, global_max_tweet].compact.min
          global_new_tweets += num_new_tweets
          global_old_tweets += num_old_tweets
          #raise
          break if num_new_tweets <= 1
        end
      end

      #Return our global counts
      puts(timeline + "_final", global_new_tweets, global_old_tweets, global_min_tweet, global_max_tweet)
      return global_new_tweets, global_old_tweets, global_min_tweet, global_max_tweet

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

  def update_friendships
    begin
      cursor = -1
      loop do
        puts("update_friendships_cursor", cursor)
        friend_ids = twitter.friend_ids(:cursor => cursor)
        start_id = 0
        while start_id + 100 <= friend_ids.ids.length
          puts("update_friendships_users", start_id, friend_ids.ids.length)
          friends = twitter.users(friend_ids.ids.slice(start_id, 100))
          for twitter_friend in friends
            friend = User.find_or_create_from_twitter(twitter_friend)
            friendship = Friendship.find_or_create_from_twitter(self, friend)
          end
          start_id += 100
        end
        cursor = friend_ids.next
        break if friend_ids.last?
      end

    #Very common to run into rate limits unintentionally, lets make sure the app doesn't die
    rescue Twitter::Error::TooManyRequests => error
      puts(
        "update_friendships_TooManyRequests",
        "limit: " + error.rate_limit.limit.to_s,
        "remaining: " + error.rate_limit.remaining.to_s,
        "reset: " + time_ago_in_words(error.rate_limit.reset_at, true) + " (" + error.rate_limit.reset_at.to_s + ")"
      )
    end
  end

  def self.bulk_insert(users)
    if users.blank?
      return 0,0
    else
      num_new_users = 0
      num_old_users = 0
      for user in users
        if !(User.where(:twitter_uid => user.id).first)
          User.create_from_twitter(user)
          num_new_users += 1
        else
          num_old_users += 1
        end
      end
      return num_new_users, num_old_users
    end
  end
end
