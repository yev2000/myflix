class Category < ActiveRecord::Base

  has_many :video_categories
  has_many :videos, through: :video_categories  

  def Category.create_from_json(json_obj)
    c = self.new
    c.name = json_obj["name"]
    return c
  end

end
