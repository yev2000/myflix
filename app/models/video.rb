class Video < ActiveRecord::Base

  has_many :video_categories
  has_many :categories, -> {order 'name'}, through: :video_categories

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
        puts "Could not find category #{cat['name']}"
      else
        v.categories << c
      end
    end

    return v
  end

end
