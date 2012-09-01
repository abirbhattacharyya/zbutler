class CreateMusics < ActiveRecord::Migration
  def self.up
    create_table :musics do |t|
      t.integer :user_id
      t.integer :friend_id,:limit => 6
      t.string :name
      t.string :category,:default => "Music"
      t.string :music_id
      t.timestamps
    end
  end

  def self.down
    drop_table :musics
  end
end
