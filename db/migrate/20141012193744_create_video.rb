class CreateVideo < ActiveRecord::Migration
  def change
    create_table :videos do |t|
      t.string  :title
      t.text    :description
      t.string  :cover_small_url
      t.string  :cover_large_url
      t.integer :year

      t.timestamps
    end
  end
end
