def seed_reviews
  # use fabricators to create a random set of reviews
  8.times do
    u = Fabricate(:user)
  end

  Video.all.each do |v|
    index = 1
    rand(0..8).times do
      r = Fabricate(:review, user: User.find(index), video: v)
      index += 1
    end
  end

  # set age in order of number of characters in the body so that we can visually eyeball that
  # sorting seems to work right
  review_list = Review.all.sort { |r1, r2| r1.body.length <=> r2.body.length }

  days_ago = 1
  review_list.each do |review|
    review.created_at = days_ago.days.ago
    review.save
    days_ago += 1
  end

end

def seed_video_age
  # set the creation time to be keyed off the movie year.
  # this is a bit of a hack but attempts to create some distribution of years.
  Video.all.each do |v|
    v.created_at = (2014 - v.year).days.ago
    v.save
  end
end

def seed_categories(filename, options = {})
  json_str = File.read(filename)
  json_obj_array = JSON.parse(json_str)

  json_obj_array.each do |entry|
    c = Category.create_from_json(entry)

    # try to find an existing video by that title already
    existing_category = Category.find_by(name: c.name)
    if existing_category.nil?
      if (c.save == false)
        puts "Could not save Category #{c.name}" unless options[:silent]
      else
        puts "Category #{c.name} created." unless options[:silent]
      end
    else
      puts "Category with name #{c.name} already exists - not adding to seed records" unless options[:silent]
    end
  end
end

def seed_videos(filename, options = {})
  json_str = File.read(filename)
  json_obj_array = JSON.parse(json_str)

  json_obj_array.each do |entry|
    v = Video.create_from_json(entry, options)

    # try to find an existing video by that title already
    existing_video = Video.find_by(title: v.title)
    if existing_video.nil?
      if (v.save == false)
        puts "Could not save Video #{v.title}" unless options[:silent]
      else
        puts "Video #{v.title} created." unless options[:silent]
      end
    else
      puts "Video with title #{v.title} already exists - not adding to seed records" unless options[:silent]
    end
  end

end
