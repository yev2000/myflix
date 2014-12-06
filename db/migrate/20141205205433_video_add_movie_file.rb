class VideoAddMovieFile < ActiveRecord::Migration
  def change
    add_column :videos, :movie_file, :string
  end
end
