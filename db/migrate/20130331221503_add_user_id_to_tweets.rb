class AddUserIdToTweets < ActiveRecord::Migration
  class Tweet < ActiveRecord::Base
    attr_accessible :user_id
    belongs_to :user, :primary_key => :twitter_uid
  end

  def up
    #Add the new column
    add_column :tweets, :user_id, :integer, :after => :id, :limit => 8, :null => false

    #Populate it with the right data from the User table
    Tweet.reset_column_information
    Tweet.all.each do |tweet|
      tweet.update_attributes!(:user_id => User.find_by_twitter_uid(tweet.twitter_uid).id)
    end

    #Add the FK to make it complete
    add_foreign_key :tweets, :users
  end

  def down
    remove_foreign_key :tweets, :users
    remove_column :tweets, :user_id
  end
end
