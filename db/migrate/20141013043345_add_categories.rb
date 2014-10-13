class AddCategories < ActiveRecord::Migration
  def change
    create_table :categories do |t|
      t.string :name

      t.timestamps
    end

    create_table :video_categories do |t|
      t.integer :video_id
      t.integer :category_id

      t.timestamps
    end
  end
end
