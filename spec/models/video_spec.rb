require 'rails_helper'

def create_video_from_test_array(test_array)
    v = Video.new
    test_array.each do |key, entry|
      v[key.to_s] = entry
    end

    v
  end


describe Video do

  # this is using the shoulda notation
  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:description) }
  it { should have_many(:categories) }

  # I can't find a way of making this be expressed via shoulda
  # so decided to implement explicitly
  it "can have many categories ordered by category name" do
    # we create many categories and assign them to a video
  
    v = Video.create(title: "multi-category-order-test", description: "a description", cover_small_url: "small.png", cover_large_url: "large.png")

    category_array = []
    ["A", "D", "C", "B"].each do |str|
      c = Category.create(name: "Category_" + str)  
  
      v.categories << c
      category_array << c
    end

    # now test that the video has all of these categories
    loaded_video = Video.find_by(title: "multi-category-order-test")
    expect(loaded_video.categories).to eq(category_array.sort {|x,y| x.name <=> y.name})
  end

  # the following are just
  # for reference, examples, exercise code
#  it "saves itself" do
#
#    test_set = {
#        title: "Test Title",
#        cover_small_url: "Test Cover URL Small",
#        cover_large_url: "Test Cover URL Large",
#        description: "A basic description.",
#        year: 2001
#      }
#
#    v = create_video_from_test_array(test_set)
#    v.save
#
#    # now we read back in from the DB and the video we just saved
#    # should be accessible    
#    read_from_db_video = Video.first
#
#    
#    test_set.each do |key, entry|
#      expect(read_from_db_video[key.to_s]).to eq(entry)
#    end
#
#    expect(read_from_db_video).to eq(v)
#  end
#
#  it "can find a video by its title" do
#
#    test_set = {
#        title: "Test Title 2",
#        cover_small_url: "Test Cover URL Small 2",
#        cover_large_url: "Test Cover URL Large2 ",
#        description: "A basic description 2.",
#        year: 2002
#      }
#
#    v = create_video_from_test_array(test_set)
#    v.save
#
#    read_from_db_video = Video.find_by(title: test_set[:title])
#
#    test_set.each do |key, entry|
#      expect(read_from_db_video[key.to_s]).to eq(entry)
#    end
#  end
#
#
#  it "can have many categories" do
#    # we create many categories and assign them to a video
#  
#    v = Video.create(title: "multi-category-test", description: "a description", cover_small_url: "small.png", cover_large_url: "large.png")
#
#    category_array = []
#    ["A", "B", "C", "D"].each do |str|
#      c = Category.create(name: "Category" + str)  
#  
#      v.categories << c
#      category_array << c
#    end
#
#    # now test that the video has all of these categories
#    loaded_video = Video.find_by(title: "multi-category-test")
#    expect(loaded_video.categories.size).to eq(category_array.size)
#
#    category_array.each do |c|
#      expect(loaded_video.categories.find_by(name: c.name)).to eq(c)
#    end
#
#    # this should be the same as the above loop?
#    expect(loaded_video.categories).to match_array(category_array)
#
#  end
#
#
#  it "must have a title to persist to the database" do
#    test_set = {
#        cover_small_url: "Test Cover URL Small",
#        cover_large_url: "Test Cover URL Large",
#        description: "A basic description.",
#        year: 2001
#      }
#
#    v = create_video_from_test_array(test_set)
#    v.save
#
#    expect(v.save).to be_falsey
#    expect(v.id).to be_nil
#  end
#
#  it "must have a description to persist to the database" do
#    test_set = {
#        title:           "Test Title for Desc Test",
#        cover_small_url: "Test Cover URL Small",
#        cover_large_url: "Test Cover URL Large",
#        year: 2001
#      }
#
#    v = create_video_from_test_array(test_set)
#    v.save
#
#    expect(v.save).to be_falsey
#    expect(v.id).to be_nil
#  end


end
