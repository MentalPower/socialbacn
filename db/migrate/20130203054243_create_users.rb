class CreateUsers < ActiveRecord::Migration
  def up
    create_table :users, :primary_key => 'twitter_uid' do |t|
      t.string :twitter_uid
      t.string :name
      t.string :oauth_token
      t.string :oauth_secret

      t.timestamps
    end
    change_column :users, :twitter_uid , "bigint unsigned"
  end

  def down
    drop_table :users
  end
end
