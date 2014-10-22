require 'rails_helper'
require Rails.root.to_s + "/lib/seed_support"

describe Review do

  # this is using the shoulda notation
  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:body) }
  it { should validate_presence_of(:rating) }
  it { should belong_to(:user) }
  it { should belong_to(:video) }
  it { should validate_numericality_of(:rating) }
  it { should_not allow_value(-1).for(:rating) }
  it { should_not allow_value(6).for(:rating) }
  it { should allow_value(0).for(:rating) }
  it { should allow_value(1).for(:rating) }
  it { should allow_value(5).for(:rating) }


  describe "uniqueness" do
    let(:user1) { Fabricate(:user) }
    let(:user2) { Fabricate(:user) }
    let(:review1) { Fabricate(:review) }
    before do
      review1.video = Video.first
      review1.user = user1
      review1.save
    end

    it "allows more than one user to write a review for a particular video" do
      review2 = Fabricate(:review)
      review2.user = user2
      review2.video = Video.first
      review2.save

      expect(Review.all.size).to eq(2)
      expect(review1.video).to eq(Video.first)
      expect(review2.video).to eq(Video.first)

    end

    it "does not allow a user to write more than one review for a video" do
      review2 = Fabricate(:review)
      review2.user = user1
      review2.video = Video.first
      expect(review2.save).to eq(false)
    end

    describe "#rating_string" do
      it "returns 'Not rated' if the rating is 0" do
        review = Fabricate(:review, rating: 0)
        expect(review.rating_string).to eq("Not rated")
      end

      it "returns '<number> / 5' for a rating of 1 to 5" do
        review = Fabricate(:review, rating: 4)
        expect(review.rating_string).to eq("4 / 5")
      end
    end


  end

end
