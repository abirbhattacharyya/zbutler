class CreateAmazonMusics < ActiveRecord::Migration
  def self.up
    create_table :amazon_musics do |t|
      t.integer :friend_id
      t.string :product_url
      t.string :name
      t.text :description
      t.float :list_price
      t.float :price
      t.string :image_url
      t.timestamps
    end
  end

  def self.down
    drop_table :amazon_musics
  end
end
