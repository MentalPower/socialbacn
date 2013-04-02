class Tweet < ActiveRecord::Base
  attr_accessible :hasGeo, :isReply, :isRetweet, :length, :numHashtags, :numMedia, :numMentions, :numURLs, :user
  belongs_to :user

  scope :home_timeline, lambda { |current_user| where("`friendships`.`network` = 'twitter' AND `friendships`.`user_id` = ? AND `friendships`.`active` = 1", current_user).joins('LEFT JOIN `friendships` ON `friendships`.`friend_id` = `tweets`.`user_id`') }
  scope :user_timeline, lambda { |current_user| where(:user_id => current_user) }

  scope :home_timeline_sorted, lambda { |current_user| where("`friendships`.`network` = 'twitter' AND `friendships`.`user_id` = ? AND `friendships`.`active` = 1", current_user).joins('LEFT JOIN `friendships` ON `friendships`.`friend_id` = `tweets`.`user_id`').order("`tweets`.`id` DESC") }
  scope :user_timeline_sorted, lambda { |current_user| where(:user_id => current_user).order("`tweets`.`id` DESC") }

  def self.create_from_twitter(twitter_tweet)
    user = User.where(:twitter_uid => twitter_tweet.user.id).first || User.create_from_twitter(twitter_tweet.user)
    create! do |tweet|
      tweet.id = twitter_tweet.id
      tweet.user_id = user.id
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
      for tweet in tweets
        max_tweet = tweet.id if max_tweet.nil?
        min_tweet = tweet.id if min_tweet.nil?

        max_tweet = [max_tweet, tweet.id].max
        min_tweet = [min_tweet, tweet.id].min
        if !(Tweet.where(:id => tweet.id).first)
          Tweet.create_from_twitter(tweet)
          num_new_tweets += 1
        else
          num_old_tweets += 1
        end
      end
      return num_new_tweets, num_old_tweets, min_tweet, max_tweet
    end
  end
end
