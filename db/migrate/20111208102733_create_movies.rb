class CreateMovies < ActiveRecord::Migration
  def self.up
    create_table :movies do |t|
      t.integer :user_id
      t.integer :friend_id,:limit => 6
      t.string :name
      t.string :category,:default => "Movies"
      t.string :movie_id
      t.timestamps
    end
  end

  def self.down
    drop_table :movies
  end
end
