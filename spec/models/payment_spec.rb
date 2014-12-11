require 'rails_helper'

describe Payment do
  it { should belong_to(:user) }
end
