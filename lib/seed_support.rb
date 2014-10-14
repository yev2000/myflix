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
