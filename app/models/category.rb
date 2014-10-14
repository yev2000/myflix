class Category < ActiveRecord::Base

  # This is not exactly following the assignment
  # because I wanted to have the option of M:M association
  # of Videos and Categories.  That each video could have
  # many categories.  Hence the use of the explicit join table
  # video_categories below.
  has_many :video_categories
  has_many :videos, -> {order 'title'}, through: :video_categories

  # the following is a class method used to assist
  # seeding the test database.  Could also be useful
  # later for import/export.
  def Category.create_from_json(json_obj)
    c = self.new
    c.name = json_obj["name"]
    return c
  end

end
