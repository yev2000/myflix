# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
require Rails.root.to_s + "/lib/seed_support"

seed_categories(Rails.root.to_s + "/db/movie_category.json")
seed_videos(Rails.root.to_s + "/db/movie_text.json")
