class Friendship < ActiveRecord::Base
  attr_accessible :network, :friend_id, :user_id, :active

  default_scope where(:active => true)

  belongs_to :user
  belongs_to :friend, :class_name => 'User'

  def self.create_from_twitter(user, friend)
    create! do |friendship|
      friendship.network = 'twitter'
      friendship.user = user
      friendship.friend = friend
      friendship.active = true
    end
  end

  def self.find_or_create_from_twitter(user, friend)
    friendship = Friendship.unscoped.where(:network => 'twitter', :user_id => user.id, :friend_id => friend.id).first || Friendship.create_from_twitter(user, friend)
    friendship.activate
    friendship
  end

  def self.deactivate_old_twitter_friendships(user)
    for friendship in Friendship.where(:network => 'twitter', :user_id => user.id)
      friendship.deactivate
    end
  end

  def activate
    self.active = true
    self.save!
  end

  def deactivate
    self.active = false
    self.save!
  end
end
