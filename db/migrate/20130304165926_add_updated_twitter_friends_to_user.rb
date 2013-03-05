class AddUpdatedTwitterFriendsToUser < ActiveRecord::Migration
  def change
    add_column :users, :updated_twitter_friends, :datetime, :after => :newest_user_tweet
  end
end
