class RenamePaymentsType < ActiveRecord::Migration
  def change
    rename_column :payments, :type, :billing_event_type
  end
end
