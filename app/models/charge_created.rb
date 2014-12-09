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
      customer_id: event.data.object.customer
      )

    Rails.logger.info "ChargeCreated: payment: #{payment}, valid: #{payment.valid?}"

    # for some strange reason, if I include an assignment
    # of type: event.type in the create() method above,
    # the error that occurs is:
    #  Invalid single-table inheritance type: charge.succeeded is not a subclass of Payment
    payment.type = event.type
    payment.save
  end
end
