class AddUidIndexToUser < ActiveRecord::Migration
  def change
    add_index :users, :uid
  end
end