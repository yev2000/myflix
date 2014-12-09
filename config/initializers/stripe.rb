if Rails.env.production?
  ### eventually will need to replace with actual non-test key
  Rails.configuration.stripe = {
    :publishable_key => ENV['stripe_test_public_key'],
    :secret_key      => ENV['stripe_test_secret_key']
  }
  Stripe.api_key = Rails.configuration.stripe[:secret_key]  
else
  Rails.configuration.stripe = {
    :publishable_key => ENV['stripe_test_public_key'],
    :secret_key      => ENV['stripe_test_secret_key']
  }

  Stripe.api_key = Rails.configuration.stripe[:secret_key]
end

StripeEvent.configure do |events|
  events.subscribe 'customer.created' do |event|
    Rails.logger.info '**************************************************'
    Rails.logger.info event
    Rails.logger.info '**************************************************'
  end

  events.subscribe 'charge.succeeded', ChargeCreated.new

end
