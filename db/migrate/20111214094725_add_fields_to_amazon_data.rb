class AddFieldsToAmazonData < ActiveRecord::Migration
  def self.up
    add_column :amazon_books, :like, :boolean, :default => false
    add_column :amazon_movies, :like, :boolean, :default => false
    add_column :amazon_musics, :like, :boolean, :default => false
  end

  def self.down
  end
end
