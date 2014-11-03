require 'rails_helper'
require Rails.root.to_s + "/lib/seed_support"

describe VideoQueueEntry do
  it { should belong_to(:user) }
  it { should belong_to(:video) }
  it { should validate_presence_of(:position) }
  it { should validate_presence_of(:user) }
  it { should validate_presence_of(:video) }
  it { should validate_numericality_of(:position) }
  it { should_not allow_value(-1).for(:position) }
  it { should_not allow_value(0).for(:position) }
  it { should allow_value(2).for(:position) }
  it { should allow_value(1).for(:position) }
  it { should allow_value(6).for(:position) }

  it "does not allow a video to be in a user's queue more than once" do
    user = Fabricate(:user)
    video = Fabricate(:video)
    Fabricate(:video_queue_entry, video: video, user: user, position: 1)
    vqe = Fabricate.build(:video_queue_entry, video: video, user: user, position: 2)

    expect(vqe.save).to eq(false) 
    expect(VideoQueueEntry.all.size).to eq(1)
  end

  describe "#review" do
    it "returns the review associated with the video and user of the queue entry" do
      user1 = Fabricate(:user)
      user2 = Fabricate(:user)
      user3 = Fabricate(:user)

      video = Fabricate(:video)

      review1 = Fabricate(:review, video: video, user: user1)
      review2 = Fabricate(:review, video: video, user: user2)
      review3 = Fabricate(:review, video: video, user: user3)     

      vqe = Fabricate(:video_queue_entry, video: video, user: user2, position: 1)

      expect(vqe.review).to eq(review2)
    end

    it "returns nil if no review is associated with the video and user of the queue entry" do
      user = Fabricate(:user)
      video = Fabricate(:video)
      vqe = Fabricate(:video_queue_entry, video: video, user: user, position: 1)

      expect(vqe.review).to be_nil
    end
  end

  describe "#rating_summary_string" do
    before do
      user = Fabricate(:user)
      video = Fabricate(:video)
      Fabricate(:video_queue_entry, video: video, user: user, position: 1)
    end

    it "returns the string representation of the rating of the review associated with the queue entry's user and video" do
      review = Fabricate(:review, video: Video.first, user: User.first, rating: 4)
      expect(VideoQueueEntry.first.rating_summary_string).to eq("4 / 5")
    end

    it "returns 'Not rated' if no review was found associated with the queue entry's user and video" do
      expect(VideoQueueEntry.first.rating_summary_string).to eq("Not rated")
    end

  end

  describe "#categories" do
    before do
      user = Fabricate(:user)
      video = Fabricate(:video)
      Fabricate(:video_queue_entry, video: video, user: user, position: 1)
    end

    it "returns the array of categories associated with the video of the queue entry" do
      c1 = Fabricate(:category)
      c2 = Fabricate(:category)
      Video.first.categories << c1
      Video.first.categories << c2

      expect(VideoQueueEntry.first.categories).to match_array([c1,c2])
    end

    it "returns empty array if no categories are associated with the video" do
      expect(VideoQueueEntry.first.categories).to eq([])
    end

  end

  describe "#self.renumber_positions!" do
    it "reorders the queue entries" do
      user = Fabricate(:user)
      vqe1 = Fabricate(:video_queue_entry, video: Fabricate(:video), user: user, position: 9)
      vqe2 = Fabricate(:video_queue_entry, video: Fabricate(:video), user: user, position: 7)
      VideoQueueEntry.renumber_positions!([vqe1, vqe2])
      vqe1.reload
      vqe2.reload
      expect(vqe1.position).to eq(1)
      expect(vqe2.position).to eq(2)
    end

    it "returns true on successful reordering" do
      user = Fabricate(:user)
      vqe1 = Fabricate(:video_queue_entry, video: Fabricate(:video), user: user, position: 9)
      vqe2 = Fabricate(:video_queue_entry, video: Fabricate(:video), user: user, position: 7)
      expect(VideoQueueEntry.renumber_positions!([vqe1, vqe2])).to eq(true)
    end

    it "returns false if at least one record could not be saved" do
      user = Fabricate(:user)
      vqe1 = Fabricate(:video_queue_entry, video: Fabricate(:video), user: user, position: 9)
      vqe2 = Fabricate(:video_queue_entry, video: Fabricate(:video), user: user, position: 7)
      vqe2.video = nil
      expect(VideoQueueEntry.renumber_positions!([vqe1, vqe2])).to eq(false)
    end

    it "does not persist any ordering changes if false is returned" do
      user = Fabricate(:user)
      vqe1 = Fabricate(:video_queue_entry, video: Fabricate(:video), user: user, position: 9)
      vqe2 = Fabricate(:video_queue_entry, video: Fabricate(:video), user: user, position: 7)
      vqe2.video = nil
      VideoQueueEntry.renumber_positions!([vqe1, vqe2])

      vqe1.reload
      vqe2.reload
      expect(vqe1.position).to eq(9)
      expect(vqe2.position).to eq(7)
    end
  end # describe #self.renumber_positions!

  describe "#rating_value" do
    before do
      @user = Fabricate(:user)
      @vqe = Fabricate(:video_queue_entry, video: Fabricate(:video), user: @user, position: 1)
    end

    it "returns the unrated_value string if there is no rating that the user provided for the video referenced by the queue entry" do
      expect(@vqe.rating_value).to eq(Review.unrated_value)
    end

    it "returns the value of the rating in the review associated with the video of the queue entry" do
      review = Fabricate(:review, video: @vqe.video, rating: 4, user: @user)
      expect(@vqe.rating_value).to eq(4)
    end
  end #rating_value
end

