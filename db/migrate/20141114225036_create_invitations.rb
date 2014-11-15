class CreateInvitations < ActiveRecord::Migration
  def change
    create_table :invitations do |t|
      t.string    :email
      t.string    :fullname
      t.string    :message
      t.string    :token
      t.integer   :user_id

      t.timestamps
    end
  end
end
