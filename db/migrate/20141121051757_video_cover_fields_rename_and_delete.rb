class VideoCoverFieldsRenameAndDelete < ActiveRecord::Migration
  def change
    add_column :videos, :large_cover, :string
    add_column :videos, :small_cover, :string
    remove_column :videos, :cover_small_url
    remove_column :videos, :cover_large_url
    remove_column :videos, :cover
  end
end
