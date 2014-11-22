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
