# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20111215093339) do

  create_table "amazon_books", :force => true do |t|
    t.integer  "friend_id"
    t.string   "product_url"
    t.string   "name"
    t.text     "description"
    t.float    "list_price"
    t.float    "price"
    t.string   "image_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "like",        :default => false
  end

  add_index "amazon_books", ["friend_id"], :name => "index_amazon_books_on_friend_id"

  create_table "amazon_movies", :force => true do |t|
    t.integer  "friend_id"
    t.string   "product_url"
    t.string   "name"
    t.text     "description"
    t.float    "list_price"
    t.float    "price"
    t.string   "image_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "like",        :default => false
  end

  add_index "amazon_movies", ["friend_id"], :name => "index_amazon_movies_on_friend_id"

  create_table "amazon_musics", :force => true do |t|
    t.integer  "friend_id"
    t.string   "product_url"
    t.string   "name"
    t.text     "description"
    t.float    "list_price"
    t.float    "price"
    t.string   "image_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "like",        :default => false
  end

  add_index "amazon_musics", ["friend_id"], :name => "index_amazon_musics_on_friend_id"

  create_table "books", :force => true do |t|
    t.integer  "user_id"
    t.integer  "friend_id",  :limit => 8
    t.string   "name"
    t.string   "category",                :default => "Books"
    t.string   "book_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "books", ["friend_id"], :name => "index_books_on_friend_id"
  add_index "books", ["user_id"], :name => "index_books_on_user_id"

  create_table "friends", :force => true do |t|
    t.integer  "user_id"
    t.integer  "uid",        :limit => 8
    t.string   "name"
    t.string   "user_name"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "sex"
    t.string   "email"
    t.string   "locale"
    t.boolean  "verified",                :default => true
    t.boolean  "is_blocked",              :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "birthdate"
    t.string   "pic_url"
  end

  create_table "movies", :force => true do |t|
    t.integer  "user_id"
    t.integer  "friend_id",  :limit => 8
    t.string   "name"
    t.string   "category",                :default => "Movies"
    t.string   "movie_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "movies", ["friend_id"], :name => "index_movies_on_friend_id"
  add_index "movies", ["user_id"], :name => "index_movies_on_user_id"

  create_table "musics", :force => true do |t|
    t.integer  "user_id"
    t.integer  "friend_id",  :limit => 8
    t.string   "name"
    t.string   "category",                :default => "Music"
    t.string   "music_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "musics", ["friend_id"], :name => "index_musics_on_friend_id"
  add_index "musics", ["user_id"], :name => "index_musics_on_user_id"

  create_table "users", :force => true do |t|
    t.integer  "fb_uid",                    :limit => 8
    t.string   "login"
    t.string   "email_hash"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
  end

  add_index "users", ["fb_uid"], :name => "index_users_on_fb_uid"

end
