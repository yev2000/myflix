require 'rails_helper'

describe Following do
  it { should belong_to(:follower) }
  it { should belong_to(:leader) }
end
