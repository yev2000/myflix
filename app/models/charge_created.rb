class ChargeCreated
  def initialize
  end

  def call(event)
    Rails.logger.info "ChargeCreated: invoked"
    Rails.logger.info "ChargeCreated: event: #{event}"

    payment = Payment.create(
      amount: event.data.object.amount.to_i,
      user: User.find_by_stripe_customer_id(event.data.object.customer),
      stripe_event_id: event.id,
      reference_id: event.data.object.id,
      billing_event_type: event.type
      )

    Rails.logger.info "ChargeCreated: payment: #{payment}, valid: #{payment.valid?}"
  end
end
