class Video < ActiveRecord::Base

  # This is not exactly following the assignment
  # because I wanted to have the option of M:M association
  # of Videos and Categories.  That each video could have
  # many categories.  Hence the use of the explicit join table
  # video_categories below.
  has_many :video_categories
  has_many :categories, -> {order 'name'}, through: :video_categories

  validates :title, :description, presence: true

  # the following is a class method used to assist
  # seeding the test database.  Could also be useful
  # later for import/export.
  def Video.create_from_json(json_obj)
    v = self.new
    v.title = json_obj["title"]
    v.description = json_obj["description"]
    v.cover_small_url = json_obj["cover_small_url"]
    v.cover_large_url = json_obj["cover_large_url"]

    # now handle setting categories
    json_obj["categories"].each do |cat|
      c = Category.find_by(name: cat["name"])
      if (c.nil?)
        ### TODO: should probably raise an exception instead
        puts "Could not find category #{cat['name']}"
      else
        v.categories << c
      end
    end

    return v
  end

end
