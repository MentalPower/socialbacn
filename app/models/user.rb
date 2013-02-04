class User < ActiveRecord::Base
  self.primary_key = 'twitter_uid'
  has_many :tweets

  def self.create_from_twitter(twitter_user)
    create! do |user|
      user.twitter_uid = twitter_user.id
      user.name = twitter_user.screen_name
    end
  end

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
      for item in twitter.home_timeline(:count => 200)
        tweet = Tweet.where(:id => item.id).first || Tweet.create_from_twitter(item)
      end
    end
  end

  def update_user_timeline
    if twitter
      for item in twitter.user_timeline(:count => 200)
        tweet = Tweet.where(:id => item.id).first || Tweet.create_from_twitter(item)
      end
    end
  end
end
