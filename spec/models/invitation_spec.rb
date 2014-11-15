require 'rails_helper'

describe Invitation do
  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:fullname) }
  it { should belong_to(:user) }
end
