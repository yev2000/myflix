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

  describe "#followers" do

    it "should return empty collection if this user is not being followed by anyone" do
      user = Fabricate(:user)

      leader = Fabricate(:user)
      bob = Fabricate(:user)
      Following.create(leader_id: leader.id, follower_id: bob.id)

      expect(user.followers).to eq([])
    end


    it "should return the collection of users who follow this user" do
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
  end # followers

  describe "#followed_leaders" do

    it "should return empty collection if this user does not follow any leader" do
      user = Fabricate(:user)

      leader = Fabricate(:user)
      bob = Fabricate(:user)
      Following.create(leader_id: leader.id, follower_id: bob.id)

      expect(user.followed_leaders).to eq([])
    end


    it "returns the collection of leaders that this user follows" do
      user = Fabricate(:user)

      alice = Fabricate(:user)
      bob = Fabricate(:user)
      charlie = Fabricate(:user)
      
      # user follows two people
      Following.create(leader: alice, follower: user)
      Following.create(leader: bob, follower: user)

      # plus bob follows charlie, but this user does not
      Following.create(leader: charlie, follower: bob)

      expect(user.followed_leaders).to eq([alice, bob])
    end
  end # followed_leaders

  describe "#follows?" do

    it "returns false if the leader specified in the input parameter is not being followed by this user" do
      user = Fabricate(:user)

      alice = Fabricate(:user)
      bob = Fabricate(:user)
      charlie = Fabricate(:user)
      
      Following.create(leader: alice, follower: bob)
      Following.create(leader: charlie, follower: alice)

      expect(user.follows?(alice)).to be false
      expect(user.follows?(charlie)).to be false
    end

    it "returns true if the leader specified in the input parameter is being followed by this user" do
      user = Fabricate(:user)

      alice = Fabricate(:user)
      bob = Fabricate(:user)
      charlie = Fabricate(:user)
      
      # user follows two people
      Following.create(leader: alice, follower: user)
      Following.create(leader: bob, follower: user)

      # plus someone follows charlie, a third person
      Following.create(leader: charlie, follower: bob)

      expect(user.follows?(alice)).to be true
      expect(user.follows?(bob)).to be true
      expect(user.follows?(charlie)).to be false
    end
  end # follows?
end
