class RenamePaymentsCustomerId < ActiveRecord::Migration
  def change
    rename_column :payments, :customer_id, :reference_id
  end
end
