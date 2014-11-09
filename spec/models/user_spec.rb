require 'rails_helper'

describe User do
  it { should validate_presence_of(:email) }
  it { should validate_uniqueness_of(:email) }
  it { should validate_presence_of(:password) }
  it { should validate_presence_of(:fullname) }
  it { should have_many(:reviews).order("created_at DESC") }
  it { should have_many(:video_queue_entries) }
  it { should have_many(:queued_videos) }
  it { should have_many(:sorted_video_queue_entries).order("position") }
  it { should have_many(:following_relationships) }
#  it { should have_many(:followers) }

  describe "#followers" do

    it "should return empty collection if no followings refer to this user" do
      user = Fabricate(:user)
      expect(user.followers).to eq([])
    end


    it "should return the collection of followings that refer to this user" do
      user = Fabricate(:user)

      follower1 = Fabricate(:user)
      follower2 = Fabricate(:user)
      follower3 = Fabricate(:user)
      Following.create(leader: user, follower: follower1)
      Following.create(leader: user, follower: follower2)
      Following.create(leader: user, follower: follower3)

      # and add some that should NOT be there
      non_follower1 = Fabricate(:user)
      non_follower2 = Fabricate(:user)
      Following.create(leader: follower1, follower: non_follower1)
      Following.create(leader: follower1, follower: non_follower2)
      Following.create(leader: follower2, follower: non_follower1)

      expect(user.followers).to eq([follower1, follower2, follower3])

    end

  end

end
