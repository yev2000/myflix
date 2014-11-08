require 'rails_helper'

describe Following do

  # this is using the shoulda notation
  it { should belong_to(:user) }
  it { should belong_to(:followed_user) }

end
