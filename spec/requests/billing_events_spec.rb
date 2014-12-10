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

  describe "charge.failed" do
    it "locks the user's account if the customer exists" do
      alice = Fabricate(:user, stripe_customer_id: "cus_5IdFSrHFGolkot")
      json_str = File.read("spec/support/fixtures/evt_charge_failed.json")
      event_data = JSON.parse(json_str)
      event_obj = Hashie::Mash.new event_data

      post '/_payments', event_obj
      alice.reload
      expect(alice.account_locked?).to eq(true)
    end

    it "does not lock any other user's account" do
      bob = Fabricate(:user, stripe_customer_id: "do_not_lock1")
      alice = Fabricate(:user, stripe_customer_id: "cus_5IdFSrHFGolkot")
      charlie = Fabricate(:user, stripe_customer_id: "do_not_lock2")

      json_str = File.read("spec/support/fixtures/evt_charge_failed.json")
      event_data = JSON.parse(json_str)
      event_obj = Hashie::Mash.new event_data

      post '/_payments', event_obj

      bob.reload
      expect(bob.account_locked?).to eq(false)

      charlie.reload
      expect(charlie.account_locked?).to eq(false)
    end

    it "does not lock an account if no related customer is found" do
      bob = Fabricate(:user, stripe_customer_id: "do_not_lock1")
      charlie = Fabricate(:user, stripe_customer_id: "do_not_lock2")

      json_str = File.read("spec/support/fixtures/evt_charge_failed.json")
      event_data = JSON.parse(json_str)
      event_obj = Hashie::Mash.new event_data

      post '/_payments', event_obj

      bob.reload
      expect(bob.account_locked?).to eq(false)

      charlie.reload
      expect(charlie.account_locked?).to eq(false)
    end

    it "sends an email to the locked out user" do
      ActionMailer::Base.deliveries.clear

      alice = Fabricate(:user, stripe_customer_id: "cus_5IdFSrHFGolkot")
      json_str = File.read("spec/support/fixtures/evt_charge_failed.json")
      event_data = JSON.parse(json_str)
      event_obj = Hashie::Mash.new event_data

      post '/_payments', event_obj

      expect(ActionMailer::Base.deliveries).not_to be_empty
      message = ActionMailer::Base.deliveries.first
      expect(message.to).to eq([alice.email])

      ActionMailer::Base.deliveries.clear
    end
  end
end

def force_bad_customer_charge_to_seed_event
  good_token = Stripe::Token.create(
    card: {
      number: "4242424242424242",
      exp_month: 3,
      exp_year: 2017,
      cvc: 314
      }
    ).id

  bad_token = Stripe::Token.create(
    card: {
      number: "4000000000000341",
      exp_month: 3,
      exp_year: 2017,
      cvc: 314
      }
    ).id

  alice = Fabricate(:user, email: "bad_charge_user@myflix.com")
  customer_creation = CustomerCreation.new(alice, good_token)
  customer_creation.create_customer

  customer_record = Stripe::Customer.retrieve(alice.stripe_customer_id)
  customer_record.card = bad_token
  customer_record.save

  begin
    Stripe::Charge.create(
      amount: User::REGISTRATION_COST_IN_CENTS,
      customer: alice.stripe_customer_id,
      currency: "usd")
  rescue Stripe::CardError => e
  end
end
