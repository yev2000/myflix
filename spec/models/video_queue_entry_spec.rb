require 'rails_helper'
require Rails.root.to_s + "/lib/seed_support"

describe VideoQueueEntry do
  it { should belong_to(:user) }
  it { should belong_to(:video) }
  it { should validate_presence_of(:position) }
  it { should validate_numericality_of(:position) }
  it { should_not allow_value(-1).for(:position) }
  it { should_not allow_value(0).for(:position) }
  it { should allow_value(2).for(:position) }
  it { should allow_value(1).for(:position) }
  it { should allow_value(6).for(:position) }

  it "does not allow a video to be in a user's queue more than once" do
    u = Fabricate(:user)
    video = Fabricate(:video)
    vqe = Fabricate(:video_queue_entry, video: video, user: u, position: 1)
    expect(VideoQueueEntry.all.size).to eq(1)
    vqe = Fabricate(:video_queue_entry, user: u, position: 2)
    vqe.video = video
    expect(vqe.save).to eq(false) 
  end
end