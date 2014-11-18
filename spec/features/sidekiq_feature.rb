# testing out sidekiq
require 'rails_helper'

Sidekiq::Testing.inline!

feature "try a sidekiq job" do
  scenario "queue a job" do
    YevWorker.perform_async("This is a test string from an rspec test ***")

    expect(true).to be true
  end
end
