require 'rails_helper'

describe StripeWrapper::Charge do
  before { StripeWrapper.set_api_key }

  let(:token) do
    token = Stripe::Token.create(
      card: {
        number: card_number,
        exp_month: 3,
        exp_year: 2017,
        cvc: 314
      }
    ).id  
  end

  context "with valid card" do
    let(:card_number) { "4242424242424242"}
    it "charges the card successfully", :vcr do
      response = StripeWrapper::Charge.create(amount: 429, card: token)
      expect(response).to be_successful
    end
  end

  context "with invalid card" do
    let(:card_number) { "4000000000000002"}
    let(:response) { StripeWrapper::Charge.create(amount: 429, card: token) }

    it "does not charge the card successfully", :vcr do
      expect(response).not_to be_successful
    end

    it "contains an error message", :vcr  do
      expect(response.error_message).to include("declined")
    end
  end
end

