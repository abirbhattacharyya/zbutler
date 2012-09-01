class AddFieldsToFriends < ActiveRecord::Migration
  def self.up
    add_column :friends, :birthdate, :date
    add_column :friends, :pic_url, :string
  end

  def self.down
  end
end
