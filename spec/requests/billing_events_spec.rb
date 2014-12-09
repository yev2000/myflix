require 'rails_helper'

describe "Billing Events", :vcr do
  def stub_event(fixture_id, status = 200)
    stub_request(:get, "https://api.stripe.com/v1/events/#{fixture_id}").
      to_return(status: status, body: File.read("spec/support/fixtures/#{fixture_id}.json"))

    stub_request(:get, "https://api.stripe.com/v2/events/#{fixture_id}").
      to_return(status: status, body: File.read("spec/support/fixtures/#{fixture_id}.json"))

  end

  describe "charge.succeeded" do
    before do
##      stub_event 'evt_charge_succeeded'
    end

    it "is successful" do
      post '/_payments', id: 'evt_156ychHLIyFXpgjHKoVF5uYo'
##      post '/_payments', id: 'evt_charge_succeeded'
      expect(response.code).to eq "200"
    end

    it "creates a new payment" do
      post '/_payments', id: 'evt_156ychHLIyFXpgjHKoVF5uYo'
      
      expect(Payment.count).to eq(1)
    end
  end
end