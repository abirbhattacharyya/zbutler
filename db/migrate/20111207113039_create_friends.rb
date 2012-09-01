class CreateFriends < ActiveRecord::Migration
  def self.up
    create_table :friends do |t|
      t.integer :user_id
      t.integer :uid, :limit => 6
      t.string :name
      t.string :user_name
      t.string :first_name
      t.string :last_name
      t.string :sex
      t.string :email
      t.string :locale
      t.boolean :verified, :default => true
      t.boolean :is_blocked, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :friends
  end
end
