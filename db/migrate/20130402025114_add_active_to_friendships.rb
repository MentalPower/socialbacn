class AddActiveToFriendships < ActiveRecord::Migration
  def change
    add_column :friendships, :active, :boolean, :after => :friend_id, :default => true
    add_index :friendships, [:network, :user_id, :active, :friend_id], :name => 'index_on_network_user_id_active_friend_id'
  end
end
