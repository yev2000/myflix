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
seed_video_age
seed_reviews

# create some fresh known user account with known passwords
# we will use these to create explicit queues that we can visit
# plus also create some video reviews for these users
alice = Fabricate(:user, email: "alice@aaa.com", fullname: "Alice Doe", password: "pass")
bob = Fabricate(:user, email: "bob@bbb.com", fullname: "Bob Doe", password: "pass")
charlie = Fabricate(:user, email: "charlie@ccc.com", fullname: "Charlie Doe", password: "pass")

# the above users are referenced in queues we seed
seed_videoqueues()
seed_specific_user_reviews([bob, charlie])

