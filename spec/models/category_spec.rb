require 'rails_helper'

def set_days_ago(video)
  video.created_at = video.title.to_i.days.ago
  video.save
end

def create_base_data_set
  c = Fabricate(:category)
  v1 = Video.create(title: "6", description: "B", categories: [c])
  v2 = Video.create(title: "4", description: "B", categories: [c])
  v3 = Video.create(title: "2", description: "B", categories: [c])
  v4 = Video.create(title: "3", description: "B", categories: [c])
  v5 = Video.create(title: "5", description: "B", categories: [c])
  v6 = Video.create(title: "7", description: "B", categories: [c])
  v7 = Video.create(title: "1", description: "B", categories: [c])
  v8 = Video.create(title: "8", description: "B", categories: [c])

  Video.all.each do |v|
    set_days_ago(v)
  end

end

describe Category do
  before do
    create_base_data_set
  end

  # this is using the shoulda notation
  it { should have_many(:videos) }
  it { should have_many(:videos).order(:title) }
  it { should validate_presence_of(:name) }

  describe "#recent_videos" do
    it "should return 6 videos if category has more than 6" do
      c = Category.first   
      expect(c.recent_videos.size).to eq(6)
    end

    it "should return videos in reverse chronological order" do
      c = Category.first

      video_array = []
      video_array << Video.find_by(title: "1")
      video_array << Video.find_by(title: "2")
      video_array << Video.find_by(title: "3")
      video_array << Video.find_by(title: "4")
      video_array << Video.find_by(title: "5")
      video_array << Video.find_by(title: "6")
      
      expect(c.recent_videos).to eq(video_array)

      # if we add a new video that is more recent, it will "bump" the oldest
      # video from the result set
      new_vid = Video.create(title: "0", description: "B", categories: [c])
      expect(c.recent_videos).to include(new_vid)
      expect(c.recent_videos).not_to include(video_array[6])
    end


    it "should return as many videos as there are, if less than 6 in the category" do

      Video.find_by(title: "1").destroy
      Video.find_by(title: "2").destroy
      Video.find_by(title: "3").destroy
      Video.find_by(title: "4").destroy

      video_array = []
      video_array << Video.find_by(title: "5")
      video_array << Video.find_by(title: "6")
      video_array << Video.find_by(title: "7")
      video_array << Video.find_by(title: "8")
      
      c = Category.first
      expect(c.recent_videos).to eq(video_array)

    end

    it "should return the empty array if there are no videos in the category" do
      category = Fabricate(:category)
      expect(category.recent_videos).to eq([])
    end
  end
end
