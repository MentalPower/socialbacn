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
end
