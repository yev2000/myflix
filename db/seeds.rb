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
# we will use these to create specific queues that we can visit
# plus also create some video reviews for these users
alice = Fabricate(:user, email: "alice@aaa.com", fullname: "Alice Doe", password: "pass")
bob = Fabricate(:user, email: "bob@bbb.com", fullname: "Bob Doe", password: "pass")
charlie = Fabricate(:user, email: "charlie@ccc.com", fullname: "Charlie Doe", password: "pass")
daisy = Fabricate(:user, email: "daisy@ddd.com", fullname: "Daisy Doe", password: "pass")
emeril = Fabricate(:user, email: "emeril@eee.com", fullname: "Emeril Doe", password: "pass")

admin = Fabricate(:admin, email: "admin@myflix.com", fullname: "Admin User", password: "admin")

seed_videoqueues()
seed_specific_user_reviews([bob, charlie])
seed_specific_followings(alice, [bob, charlie])
seed_specific_followings(bob, [daisy, emeril])
seed_specific_followings(emeril, [charlie, daisy, bob])

