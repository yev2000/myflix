require 'rails_helper'

describe StripeWrapper do
  describe StripeWrapper::Charge do
    
    describe ".create" do
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
          amount = 429

          response = StripeWrapper::Charge.create(amount: amount, card: token)
          expect(response).to be_successful
          expect(response.amount).to eq(amount)
          expect(response.currency).to eq("usd")
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
    end # create
  end # Charge
end # StripeWrapper


