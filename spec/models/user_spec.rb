require 'rails_helper'

describe User do
  it { should validate_presence_of(:email) }
  it { should validate_uniqueness_of(:email) }
  it { should validate_presence_of(:password) }
  it { should validate_presence_of(:fullname) }
  it { should have_many(:reviews)}
  it { should have_many(:video_queue_entries) }

  ### don't know how to write the "position" requirement of the test
  it { should have_many(:queued_videos) }

end
