class User < ActiveRecord::Base
  self.primary_key = 'twitter_uid'

  def self.from_omniauth(auth)
    if auth.provider == "twitter"
      user = where(:twitter_uid => auth.uid).first || create_from_omniauth(auth)
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
end
