require 'rails_helper'
require Rails.root.to_s + "/lib/seed_support"

def create_base_video_set
  seed_videos(Rails.root.to_s + "/db/movie_text.json", {silent: true, skip_category: true})
end

describe Video do
  before do
    create_base_video_set
  end

  # this is using the shoulda notation
  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:description) }
  it { should have_many(:categories).order("name") }

  #########################################
  #
  # Tests for the Video title search
  #
  #########################################
  describe "#search_by_title" do
    it "returns empty array for no matches" do
      expect(Video.search_by_title("Godfather")).to eq([])
    end

    it "returns empty array for no matches on string with spaces where each word is individually a match" do
      # seed videos with a reference set of videos
      expect(Video.search_by_title("Green October")).to eq([])
      expect(Video.search_by_title("green october")).to eq([])
    end

    it "returns a single match for a single exact match" do
      expect(Video.search_by_title("Forrest Gump")).to eq([Video.find_by(title: "Forrest Gump")])
    end

    it "returns an array of matches for a multiple match" do
      expect(Video.search_by_title("The")).to match_array(
        [
          Video.find_by(title: "The Hunt for Red October"),
          Video.find_by(title: "The Usual Suspects")
          ])

    end

    it "returns matches case-insensitive" do
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

    # I did not think of the following - got this after
    # viewing the solution.
    it "returns matches ordered by created_at" do

      # modify the created_at timestamps of certain records
      v = Video.find_by(title: "The Usual Suspects")
      v.created_at = 1.day.ago
      v.save

      v = Video.find_by(title: "The Hunt for Red October")
      v.created_at = 2.day.ago
      v.save

      v = Video.find_by(title: "Forrest Gump")
      v.created_at = 3.day.ago
      v.save

      expect(Video.search_by_title("u")).to eq([
        Video.find_by(title: "The Usual Suspects"),
        Video.find_by(title: "The Hunt for Red October"),
        Video.find_by(title: "Forrest Gump")
        ])
    end

    it "returns empty array for an empty string" do
      expect(Video.search_by_title("")).to eq([])
    end

    it "returns empty array for a nil input" do
      expect(Video.search_by_title(nil)).to eq([])
    end


  end
end
