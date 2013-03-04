class Tweet < ActiveRecord::Base
  attr_accessible :hasGeo, :isReply, :isRetweet, :length, :numHashtags, :numMedia, :numMentions, :numURLs, :user
  belongs_to :user

  def self.create_from_twitter(twitter_tweet)
    user = User.where(:twitter_uid => twitter_tweet.user.id).first || User.create_from_twitter(twitter_tweet.user)
    create! do |tweet|
      tweet.id = twitter_tweet.id
      tweet.user = user
      tweet.length = twitter_tweet.text.length
      tweet.numURLs = twitter_tweet.urls.length
      tweet.numHashtags = twitter_tweet.hashtags.length
      tweet.numMentions = twitter_tweet.user_mentions.length
      tweet.numMedia = twitter_tweet.media.length
      tweet.hasGeo = !twitter_tweet.geo.blank?
      tweet.isReply = !twitter_tweet.in_reply_to_status_id.blank?
      tweet.isRetweet = !twitter_tweet.retweeted_tweet.blank?
      tweet.created_at = twitter_tweet.created_at
    end
  end

  def self.bulk_insert(tweets)
    if tweets.blank?
      return 0,0,nil,nil
    else
      max_tweet = nil
      min_tweet = nil
      num_new_tweets = 0
      num_old_tweets = 0
      for item in tweets
        max_tweet = item.id if max_tweet.nil?
        min_tweet = item.id if min_tweet.nil?

        max_tweet = [max_tweet, item.id].max
        min_tweet = [min_tweet, item.id].min
        if !(Tweet.where(:id => item.id).first)
          Tweet.create_from_twitter(item)
          num_new_tweets += 1
        else
          num_old_tweets += 1
        end
      end
      return num_new_tweets, num_old_tweets, min_tweet, max_tweet
    end
  end
end
