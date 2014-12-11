class AddAccountLockedToUsers < ActiveRecord::Migration
  def change
    add_column :users, :account_locked, :boolean
  end
end
