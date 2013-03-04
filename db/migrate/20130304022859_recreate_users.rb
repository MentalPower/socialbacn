class RecreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.integer :twitter_uid, :limit => 8
      t.string :name
      t.string :oauth_token
      t.string :oauth_secret
      t.integer :newest_home_tweet, :limit => 8
      t.integer :newest_user_tweet, :limit => 8
      t.timestamps
    end

    add_index :users, :twitter_uid, :unique => true
  end
end
