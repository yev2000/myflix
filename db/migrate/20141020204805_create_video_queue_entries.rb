class CreateVideoQueueEntries < ActiveRecord::Migration
  def change
    create_table :video_queue_entries do |t|
      t.integer :video_id
      t.integer :user_id
      t.integer :position
      
      t.timestamps
    end
  end
end
