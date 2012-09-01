class AddIndexInAllTables < ActiveRecord::Migration
  def self.up

    add_index :amazon_books,:friend_id
    add_index :amazon_movies,:friend_id
    add_index :amazon_musics,:friend_id

    add_index :books,:friend_id
    add_index :books,:user_id

    add_index :musics,:friend_id
    add_index :musics,:user_id

    add_index :movies,:friend_id
    add_index :movies,:user_id

    add_index :users,:fb_uid

  end

  def self.down
    remove_index :amazon_books,:friend_id
    remove_index :amazon_movies,:friend_id
    remove_index :amazon_musics,:friend_id

    remove_index :books,:friend_id
    remove_index :books,:user_id

    remove_index :musics,:friend_id
    remove_index :musics,:user_id

    remove_index :movies,:friend_id
    remove_index :movies,:user_id

    remove_index :users,:fb_uid
  end
end
