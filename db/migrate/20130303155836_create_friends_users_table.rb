class CreateFriendsUsersTable < ActiveRecord::Migration
  def up
    create_table :friends_users, :id => false do |t|
        t.integer :friend_id
        t.integer :user_id
    end
    add_index :friends_users, [:friend_id, :user_id]
  end

  def down
    drop_table :friends_users
  end
end
