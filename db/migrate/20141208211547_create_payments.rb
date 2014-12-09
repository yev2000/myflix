class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.integer     :stripe_event_id
      t.integer     :user_id
      t.string      :type
      t.integer     :amount
      t.string      :customer_id
      t.timestamps
    end
  end
end
