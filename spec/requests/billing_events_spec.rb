require 'rails_helper'

describe "Billing Events", :vcr do
  def stub_event(fixture_id, status = 200)
    stub_request(:get, "https://api.stripe.com/v1/events/#{fixture_id}").
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
      expect(Payment.first.reference_id).not_to be_nil
    end

    it "creates a payment associated with the user whose customer id matches the event's customer ID" do
      alice = Fabricate(:user, stripe_customer_id: "123")
      bob = Fabricate(:user, stripe_customer_id: "cus_5HXiceCR5pyyM9")
      charlie = Fabricate(:user, stripe_customer_id: "456")
      
      post '/_payments', id: 'evt_156ychHLIyFXpgjHKoVF5uYo'
      expect(Payment.first.user).to eq(bob)
    end

    it "creates a payment with the appropriate amount" do
      post '/_payments', id: 'evt_156ychHLIyFXpgjHKoVF5uYo'
      expect(Payment.first.amount).to eq(999)
    end

  end
end