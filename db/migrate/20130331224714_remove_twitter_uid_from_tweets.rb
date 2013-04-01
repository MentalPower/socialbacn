class RemoveTwitterUidFromTweets < ActiveRecord::Migration
  class Tweet < ActiveRecord::Base
    attr_accessible :twitter_uid
    belongs_to :user
  end

  def up
    remove_foreign_key :tweets, column: 'twitter_uid'
    remove_column :tweets, :twitter_uid
  end

  def down
    #Add the new column
    add_column :tweets, :twitter_uid, :integer, :after => :user_id, :limit => 8, :null => false

    #Populate it with the right data from the User table
    Tweet.reset_column_information
    Tweet.all.each do |tweet|
      tweet.update_attributes!(:twitter_uid => User.find_by_id(tweet.user_id).twitter_uid)
    end

    #Add the FK to make it complete
    add_foreign_key :tweets, :users, dependent: :delete, column: 'twitter_uid', primary_key: 'twitter_uid'
  end
end
