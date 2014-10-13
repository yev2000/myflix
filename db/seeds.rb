# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

json_str = File.read(Rails.root.to_s + "/db/movie_category.json")
json_obj_array = JSON.parse(json_str)

json_obj_array.each do |entry|
  c = Category.create_from_json(entry)

  # try to find an existing video by that title already
  existing_category = Category.find_by(name: c.name)
  if existing_category.nil?
    if (c.save == false)
      puts "Could not save Category #{c.name}"
    else
      puts "Category #{c.name} created."
    end
  else
    puts "Category with name #{c.name} already exists - not adding to seed records"
  end
end

json_str = File.read(Rails.root.to_s + "/db/movie_text.json")
json_obj_array = JSON.parse(json_str)

json_obj_array.each do |entry|
  v = Video.create_from_json(entry)

  # try to find an existing video by that title already
  existing_video = Video.find_by(title: v.title)
  if existing_video.nil?
    if (v.save == false)
      puts "Could not save Video #{v.title}"
    else
      puts "Video #{v.title} created."
    end
  else
    puts "Video with title #{v.title} already exists - not adding to seed records"
  end

end
