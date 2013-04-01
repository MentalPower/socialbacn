module HomeHelper
  def link_to_twitter_tweet(twitter_tweet)
    link_to(
      twitter_tweet.user.name + " (" + twitter_tweet.created_at.to_s + ")",
      "https://twitter.com/" + twitter_tweet.user.name + "/status/" +
      twitter_tweet.id.to_s,
      :target => "_blank"
    )
  end

  def link_to_twitter_user(twitter_user)
    link_to(
      twitter_user.name,
      "https://twitter.com/" + twitter_user.name,
      :target => "_blank"
    )
  end
end
