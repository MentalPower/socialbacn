class DropUsers < ActiveRecord::Migration
  def up
    drop_table :users
  end

  def down
    create_table :users, :primary_key => 'twitter_uid' do |t|
      t.string :twitter_uid
      t.string :name
      t.string :oauth_token
      t.string :oauth_secret

      t.timestamps
    end
    change_column :users, :twitter_uid , "bigint unsigned"

    add_column :users, :newest_home_tweet, :string
    add_column :users, :newest_user_tweet, :string

    change_column :users, :newest_home_tweet , "bigint unsigned"
    change_column :users, :newest_user_tweet , "bigint unsigned"
  end
end
