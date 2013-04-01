module HomeHelper
  def link_to_twitter(tweet)
    link_to(
      tweet.user.name + " (" + tweet.created_at.to_s + ")",
      "https://twitter.com/" + tweet.user.name + "/status/" +
      tweet.id.to_s,
      :target => "_blank"
    )
  end
end
