require 'rails_helper'

describe Following do

  # this is using the shoulda notation
  it { should belong_to(:follower) }
  it { should belong_to(:leader) }

end
