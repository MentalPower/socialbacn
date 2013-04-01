class RenameUserIdInTweets < ActiveRecord::Migration
  def up
    remove_foreign_key :tweets, column: 'user_id'
    rename_column :tweets, :user_id, :twitter_uid
    add_foreign_key :tweets, :users, dependent: :delete, column: 'twitter_uid', primary_key: 'twitter_uid'
  end

  def down
    remove_foreign_key :tweets, column: 'twitter_uid'
    rename_column :tweets, :twitter_uid, :user_id
    add_foreign_key :tweets, :users, dependent: :delete, column: 'user_id', primary_key: 'twitter_uid'
  end
end
