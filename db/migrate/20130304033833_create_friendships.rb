class CreateFriendships < ActiveRecord::Migration
  def change
    create_table :friendships do |t|
      t.string  :network
      t.integer :user_id, :limit => 8
      t.integer :friend_id, :limit => 8

      t.timestamps
    end

    add_index :friendships, [:network, :user_id, :friend_id], :unique => true
    add_foreign_key :friendships, :users, dependent: :delete, column: 'user_id'
    add_foreign_key :friendships, :users, dependent: :delete, column: 'friend_id'
  end
end
