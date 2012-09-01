class CreateBooks < ActiveRecord::Migration
  def self.up
    create_table :books do |t|
      t.integer :user_id
      t.integer :friend_id,:limit => 6
      t.string :name
      t.string :category,:default => "Books"
      t.string :book_id
      t.timestamps
    end
  end

  def self.down
    drop_table :books
  end
end
