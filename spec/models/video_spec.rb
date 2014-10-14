require 'rails_helper'
require Rails.root.to_s + "/lib/seed_support"

def create_base_video_set
  seed_videos(Rails.root.to_s + "/db/movie_text.json", {silent: true, skip_category: true})
end

describe Video do

  # this is using the shoulda notation
  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:description) }
  it { should have_many(:categories).order("name") }

  describe "#search_by_title" do
    it "returns empty array for no matches" do
      # seed videos with a reference set of videos
      create_base_video_set
      expect(Video.search_by_title("Godfather")).to eq([])
      expect(Video.search_by_title("Green October")).to eq([])
      expect(Video.search_by_title("green october")).to eq([])
    end

    it "returns a single match for a single exact match" do
      create_base_video_set

      expect(Video.search_by_title("Forrest Gump")).to eq([Video.find_by(title: "Forrest Gump")])
    end

    it "returns an array of matches for a multiple match" do
      create_base_video_set

      expect(Video.search_by_title("The")).to match_array(
        [
          Video.find_by(title: "The Hunt for Red October"),
          Video.find_by(title: "The Usual Suspects")
          ])

    end

    it "returns matches case-insensitive" do
      create_base_video_set
      expect(Video.search_by_title("the")).to match_array(
        [
          Video.find_by(title: "The Hunt for Red October"),
          Video.find_by(title: "The Usual Suspects")
          ])            

      expect(Video.search_by_title("u")).to match_array(
        [
          Video.find_by(title: "The Hunt for Red October"),
          Video.find_by(title: "The Usual Suspects"),
          Video.find_by(title: "Forrest Gump")
          ])            

    end
  end
end
