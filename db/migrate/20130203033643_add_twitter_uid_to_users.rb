class AddTwitterUidToUsers < ActiveRecord::Migration
  def up
    remove_column :users, :provider
    rename_column :users, :uid, :twitter_uid
  end

  def down
    add_column :users, :provider, :string, {:default => 'twitter'}
    rename_column :users, :twitter_uid, :uid
  end
end
