class Video < ActiveRecord::Base

  # This is not exactly following the assignment
  # because I wanted to have the option of M:M association
  # of Videos and Categories.  That each video could have
  # many categories.  Hence the use of the explicit join table
  # video_categories below.
  has_many :video_categories
  has_many :categories, -> {order 'name'}, through: :video_categories
  has_many :reviews, -> {order 'created_at DESC'}

  validates :title, :description, presence: true

  # the following is are class methods used to assist
  # seeding the test database.  Could also be useful
  # later for import/export.
  def self.set_categories_from_json(json_obj, video_obj, options = {})
    json_obj["categories"].each do |cat|
      c = Category.find_by(name: cat["name"])
      if (c.nil?)
        ### TODO: should probably raise an exception instead
        puts "Could not find category #{cat['name']}" unless options[:silent]
      else
        video_obj.categories << c
      end
    end 
  end

  def self.create_from_json(json_obj, options = {})
    v = self.new
    v.title = json_obj["title"]
    v.description = json_obj["description"]
    v.cover_small_url = json_obj["cover_small_url"]
    v.cover_large_url = json_obj["cover_large_url"]
    v.year = json_obj["age"].to_i

    # now handle setting categories
    set_categories_from_json(json_obj, v, options) unless options[:skip_category]

    return v
  end

  def self.search_by_title(title_name)
    # returns array of videos whose title contains title_name
    # search is case insensitive
    return [] if title_name.blank?
    self.where("title #{DATABASE_OPERATOR[:like_operator]} ?", "%#{title_name}%").order("created_at DESC")
  end

  def self.update_review_ratings!(entry_to_rating_mapping_array, user)
    # incoming array is mapping videos to updated ratings and contains an entry for a review, if
    # an existing review is found.
    entry_to_rating_mapping_array.each do |entry|
      review = entry[:review]
      if review
        # this will save the review even if it's invalid
        review.update_attribute(:rating, entry[:new_rating])
      else
        # we have a video which has not yet been reviewed by the user
        # so we have to create a "blank" review
        Review.rating_only_review_create!(rating: entry[:new_rating], video: entry[:video], user: user)

        ### to do: deal with errors
      end
    end
  end


  def average_rating_string
    avg_val = self.average_rating
    if avg_val > 0
      if ((avg_val % 1) > 0)
        # this is not an integer, so use sprintf to format
        return sprintf("%.1f / 5.0", avg_val)
      else
        # this is an integer so just return the string value
        return "#{avg_val.to_i} / 5.0"
      end
    else
      return "No ratings"
    end
  end


  def average_rating
    avg_calc = reviews.inject({total: 0, items: 0}) do |avg_accumulation, review|
      if review.rating > 0
        {
          total: avg_accumulation[:total] + review.rating,
          items: avg_accumulation[:items] + 1
        }
      else
        avg_accumulation
      end
    end

    if avg_calc[:items] > 0
      return (avg_calc[:total].to_f / avg_calc[:items])
    else
      return 0
    end
  end
end
