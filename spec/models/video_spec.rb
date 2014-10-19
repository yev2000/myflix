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
  it { should have_many(:reviews).order("created_at DESC") }

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
          Video.find_by(title: "Forrest Gump"),
          Video.find_by(title: "Apocalypse Now Redux")
          ])            
    end

    # I did not think of the following - got this after
    # viewing the solution.
    it "returns matches ordered by created_at" do
      # modify the created_at timestamps of certain records
      v = Video.find_by(title: "The Usual Suspects")
      v.created_at = 10.day.ago
      v.save

      v = Video.find_by(title: "The Hunt for Red October")
      v.created_at = 11.day.ago
      v.save

      v = Video.find_by(title: "Apocalypse Now Redux")
      v.created_at = 12.day.ago
      v.save

      v = Video.find_by(title: "Forrest Gump")
      v.created_at = 13.day.ago
      v.save

      expect(Video.search_by_title("u")).to eq([
        Video.find_by(title: "The Usual Suspects"),
        Video.find_by(title: "The Hunt for Red October"),
        Video.find_by(title: "Apocalypse Now Redux"),
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

  context "ratings" do
    let(:video) { Fabricate(:video) }
    let(:user) { Fabricate(:user) }
    let(:review1) { Fabricate(:review) }

    describe "#average_rating" do
      it "returns 0 if video has no review" do
        expect(video.average_rating).to eq(0)
      end

      it "returns 0 if all reviewed videos have no ratings" do
        review1.video = video
        review1.user = user
        review1.rating = 0
        review1.save

        expect(video.average_rating).to eq(0)
      end

      it "returns the rating value of the review if there is only 1 review with a non-zero rating" do
        review1.video = video
        review1.user = user
        review1.rating = 3
        review1.save

        6.times do
          u = Fabricate(:user)
          r = Fabricate(:review)
          r.video = video
          r.rating = 0
          r.user = u
          r.save
        end

        expect(Review.all.size).to eq(7)
        expect(video.average_rating).to eq(3)
      end

      it "returns the rating value of all reviews if they all have the same value" do
        6.times do
          u = Fabricate(:user)
          r = Fabricate(:review)
          r.video = video
          r.user = u
          r.rating = 4
          r.save
        end
        expect(Review.all.size).to eq(6)
        expect(video.average_rating).to eq(4)
      end

      it "returns the average of the non-zero rating values of reviews" do
        review1.video = video
        review1.user = user
        review1.rating = 3
        review1.save
        user2 = Fabricate(:user)
        review2 = Fabricate(:review)
        review2.video = video
        review2.user = user2
        review2.rating = 1
        review2.save
        
        expect(video.average_rating).to eq(2)
      end

    end

    describe "#average_rating_string" do
      it "returns 'No ratings' if there are no reviews for a video" do
        expect(video.average_rating_string).to eq("No ratings")
      end

      it "returns 'No ratings' if there are no reviews with ratings for a video" do
        review1.video = video
        review1.user = user
        review1.rating = 0
        review1.save
        expect(video.reviews).to eq([review1])
        expect(video.average_rating_string).to eq("No ratings")
      end

      it "returns the string representing the average rating of a video which has a non-zero integer average suffixed by ' / 5.0'" do
        review1.video = video
        review1.user = user
        review1.rating = 4
        review1.save
        expect(video.reviews).to eq([review1])
        expect(video.average_rating_string).to eq("4 / 5.0")
      end

      it "returns the string representing the average rating to 1 decimal place of precision for a video which has a non-zero non-integer average suffixed by ' / 5.0'" do
        review1.video = video
        review1.user = user
        review1.rating = 4
        review1.save

        2.times do
          u = Fabricate(:user)
          r = Fabricate(:review)
          r.video = video
          r.user = u
          r.rating = 3
          r.save
        end

        expect(video.average_rating_string).to eq(sprintf("%.1f / 5.0", (4.0+3.0+3.0)/3.0))

      end

    end
  
  end

end
