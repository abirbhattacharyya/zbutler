class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.integer :fb_uid, :limit => 6
      t.string :login
      t.string :email_hash

      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
