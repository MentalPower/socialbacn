# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130304033833) do

  create_table "friendships", :force => true do |t|
    t.string   "network"
    t.integer  "user_id",    :limit => 8
    t.integer  "friend_id",  :limit => 8
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
  end

  add_index "friendships", ["friend_id"], :name => "friendships_friend_id_fk"
  add_index "friendships", ["network", "user_id", "friend_id"], :name => "index_friendships_on_network_and_user_id_and_friend_id", :unique => true
  add_index "friendships", ["user_id"], :name => "friendships_user_id_fk"

  create_table "tweets", :force => true do |t|
    t.integer  "user_id",     :limit => 8
    t.integer  "length",                   :null => false
    t.integer  "numURLs",                  :null => false
    t.integer  "numMedia",                 :null => false
    t.integer  "numHashtags",              :null => false
    t.integer  "numMentions",              :null => false
    t.boolean  "hasGeo",                   :null => false
    t.boolean  "isReply",                  :null => false
    t.boolean  "isRetweet",                :null => false
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
  end

  add_index "tweets", ["user_id"], :name => "tweets_user_id_fk"

  create_table "users", :force => true do |t|
    t.integer  "twitter_uid",       :limit => 8
    t.string   "name"
    t.string   "oauth_token"
    t.string   "oauth_secret"
    t.integer  "newest_home_tweet", :limit => 8
    t.integer  "newest_user_tweet", :limit => 8
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  add_index "users", ["twitter_uid"], :name => "index_users_on_twitter_uid", :unique => true

  add_foreign_key "friendships", "users", :name => "friendships_friend_id_fk", :column => "friend_id", :dependent => :delete
  add_foreign_key "friendships", "users", :name => "friendships_user_id_fk", :dependent => :delete

  add_foreign_key "tweets", "users", :name => "tweets_user_id_fk", :primary_key => "twitter_uid", :dependent => :delete

end
