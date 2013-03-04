class Friendship < ActiveRecord::Base
  attr_accessible :network, :friend_id, :user_id

  belongs_to :user
  belongs_to :friend, :class_name => 'User'

  def self.create_from_twitter(user, friend)
    create! do |friendship|
      friendship.network = 'twitter'
      friendship.user = user
      friendship.friend = friend
    end
  end

  def self.find_or_create_from_twitter(user, friend)
    Friendship.where(:network => 'twitter', :user_id => user.id, :friend_id => friend.id).first || Friendship.create_from_twitter(user, friend)
  end
end
