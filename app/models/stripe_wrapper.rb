module StripeWrapper

  class BaseOperation
    attr_reader :response, :status

    def initialize(response, status)
      @response = response
      @status = status
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
      begin
        response = Stripe::Charge.create(amount: options[:amount],
          currency: "usd",
          card: options[:card],
          description: options[:description])
        new(response, :success)
      rescue Stripe::CardError => e
        new(e, :error)
      end
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
      begin
        response = Stripe::Customer.create(
          card: options[:card],
          plan: options[:plan],
          email: options[:email]
          )
        new(response, :success)
      rescue Stripe::CardError => e
        new(e, :error)
      end
    end

    def id
      response.id
    end
  end

end
