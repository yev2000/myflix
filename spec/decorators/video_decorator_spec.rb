require 'rails_helper'

describe VideoDecorator do
  let(:video) { Fabricate(:video).decorate }
  let(:user) { Fabricate(:user) }
  let(:review1) { Fabricate(:review) }

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
        r = Fabricate(:review, video: video, user: u, rating: 3)
      end

      expect(video.average_rating_string).to eq(sprintf("%.1f / 5.0", (4.0+3.0+3.0)/3.0))
    end
  end
end

