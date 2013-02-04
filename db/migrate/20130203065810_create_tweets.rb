class CreateTweets < ActiveRecord::Migration
  def up
    create_table :tweets do |t|
      t.integer :user_id, :null => false
      t.integer :length, :null => false
      t.integer :numURLs, :null => false
      t.integer :numMedia, :null => false
      t.integer :numHashtags, :null => false
      t.integer :numMentions, :null => false
      t.boolean :hasGeo, :null => false
      t.boolean :isReply, :null => false
      t.boolean :isRetweet, :null => false

      t.timestamps
    end

    change_column :tweets, :id , "bigint unsigned"
    change_column :tweets, :user_id , "bigint unsigned"
    add_foreign_key :tweets, :users, dependent: :delete, primary_key: 'twitter_uid'
  end

  def down
    drop_table :tweets
  end
end
