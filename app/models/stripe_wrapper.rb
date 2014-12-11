module StripeWrapper

  class BaseOperation
    attr_reader :response, :status

    def initialize(response, status)
      @response = response
      @status = status
    end

    def self.perform_action(&body)
      begin
        response = yield
        new(response, :success)
      rescue Stripe::CardError => e
        new(e, :error)
      end
    end

    def successful?
      status == :success
    end

    def error_message
      response.message
    end

  end

  class Charge < BaseOperation

    def self.create(options={})
      perform_action { Stripe::Charge.create(amount: options[:amount],
          currency: "usd",
          card: options[:card],
          description: options[:description]) }
    end

    def currency
      response.currency
    end

    def amount
      response.amount
    end

  end # Charge

  class Customer < BaseOperation
    attr_reader :response, :status

    def self.create(options={})
      perform_action { Stripe::Customer.create(
          card: options[:card],
          plan: options[:plan],
          email: options[:email]
          ) }
    end

    def id
      response.id
    end
  end

end
