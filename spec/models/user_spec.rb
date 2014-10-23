require 'rails_helper'

describe User do
  it { should validate_presence_of(:email) }
  it { should validate_uniqueness_of(:email) }
  it { should validate_presence_of(:password) }
  it { should validate_presence_of(:fullname) }
  it { should have_many(:reviews)}
  it { should have_many(:video_queue_entries) }
  it { should have_many(:queued_videos) }
  it { should have_many(:sorted_video_queue_entries).order("position") }
end
