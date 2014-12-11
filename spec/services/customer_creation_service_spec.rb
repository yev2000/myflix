require 'rails_helper'

describe CustomerCreation do
  describe "#create_customer" do
    context "valid credit card info" do
      before do
        customer = double('customer', successful?: true, id: "CUSTOMER_ID")
        StripeWrapper::Customer.should_receive(:create).and_return(customer)

        @user = Fabricate.build(:user, email: "bob@bbb.com")

        @creation_service = CustomerCreation.new(@user, { stripeToken: "123" })
      end

      it "returns a successful creation object" do
        return_value = @creation_service.create_customer
        expect(return_value.successful?).to eq(true)
      end

      it "sets the user's stripe_customer_id to a new customer ID" do
        return_value = @creation_service.create_customer
        expect(@user.stripe_customer_id).to eq("CUSTOMER_ID")
      end

    end # valid credit card info

    context "invalid credit card info (unsuccessful charge)" do
      before do
        customer = double('charge', successful?: false, error_message: "Your card was declined.")
        StripeWrapper::Customer.should_receive(:create).and_return(customer)

        @user = Fabricate.build(:user, email: "bob@bbb.com")

        @creation_service = CustomerCreation.new(@user, { stripeToken: "123" })
      end

      it "returns an unsuccessful creation object" do
        return_value = @creation_service.create_customer
        expect(return_value.successful?).to eq(false)
      end

      it "sets an error message" do
        return_value = @creation_service.create_customer
        expect(return_value.error_message).not_to be_nil
      end

      it "does not set the user's customer ID" do
        return_value = @creation_service.create_customer
        expect(@user.stripe_customer_id).to be_nil
      end
    end # invalid credit card info

  end # create_customer
end
