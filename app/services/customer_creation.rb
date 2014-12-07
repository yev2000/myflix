class CustomerCreation

  attr_reader :error_message

  def initialize(user, credit_card_token)
    @user = user
    @stripe_token = credit_card_token
  end

  def create_customer
    response = StripeWrapper::Customer.create(card: @stripe_token, plan: User::MONTHLY_PLAN_ID, email: @user.email)
    if response.successful?
      @creation_success = true
      @user.stripe_customer_id = response.id
    else
      @error_message = "Error in processing your credit card (#{response.error_message})"
      @creation_success = false
    end

    return self
  end

  def successful?
    @creation_success
  end

end
