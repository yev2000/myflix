require 'rails_helper'

describe Payment do
  # this is using the shoulda notation
  it { should belong_to(:user) }

end
