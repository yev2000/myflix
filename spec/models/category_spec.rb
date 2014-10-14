require 'rails_helper'

describe Category do

  # this is using the shoulda notation
  it { should have_many(:videos) }
  it { should have_many(:videos).order("title") }

#  # the following are just
#  # for reference, examples, exercise code
#  it "saves itself" do
#
#    test_set = {
#        name: "Test Category Name"
#      }
#
#    c = Category.new
#    test_set.each do |key, entry|
#      c[key.to_s] = entry
#    end
#
#    c.save
#
#    # now we read back in from the DB and the video we just saved
#    # should be accessible    
#    read_from_db_category = Category.first
#    
#    test_set.each do |key, entry|
#      expect(read_from_db_category[key.to_s]).to eq(entry)
#    end
#
#    expect(read_from_db_category).to eq(c)
#  end

  # we create a category and assign many videos to it
#  it "can have many videos" do
#
#    c = Category.create(name: "multi-video-test")
#
#    test_video_set = {
#        title: "Test Title",
#        cover_small_url: "Test Cover URL Small",
#        cover_large_url: "Test Cover URL Large ",
#        description: "A basic description.",
#      }
#
#    video_array = []
#    ["A", "B", "C", "D"].each do |str|
#      v = Video.new
#      test_video_set.each do |key, entry|
#        v[key.to_s] = entry + str
#      end
#
#      v.save
#      c.videos << v
#      video_array << v
#    end
#
#    # now test that the specific category has those videos
#    loaded_category = Category.find_by(name: "multi-video-test")
#    expect(loaded_category.videos.size).to eq(video_array.size)
#
#    video_array.each do |v|
#      expect(loaded_category.videos.find_by(title: v.title)).to eq(v)
#    end
#    
#    expect(loaded_category.videos).to match_array(video_array)
#  end
#

end