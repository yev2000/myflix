class ChangeFollowingColumnNames < ActiveRecord::Migration
  def change
    rename_column :followings, :user_id, :follower_id
    rename_column :followings, :followed_user_id, :leader_id
  end
end
