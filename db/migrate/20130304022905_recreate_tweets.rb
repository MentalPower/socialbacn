class RecreateTweets < ActiveRecord::Migration
  def change
    create_table :tweets do |t|
      #Technically user_ID is NOT NULL, but the foreign key
      #will refuse to form if the column types don't match.
      t.integer :user_id, :limit => 8
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

    add_foreign_key :tweets, :users, dependent: :delete, column: 'user_id', primary_key: 'twitter_uid'
  end
end
