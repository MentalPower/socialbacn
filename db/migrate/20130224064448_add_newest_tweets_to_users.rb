class AddNewestTweetsToUsers < ActiveRecord::Migration
  def up
    add_column :users, :newest_home_tweet, :string
    add_column :users, :newest_user_tweet, :string

    change_column :users, :newest_home_tweet , "bigint unsigned"
    change_column :users, :newest_user_tweet , "bigint unsigned"
  end

  def down
    remove_column :users, :newest_home_tweet
    remove_column :users, :newest_user_tweet
  end
end
