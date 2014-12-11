class ChargeFailed
  def call(event)
    Rails.logger.info "ChargeFailed: event: #{event}"

    user = User.find_by_stripe_customer_id(event.data.object.customer)
    return if user.nil?

    user.account_locked = true
    user.save

    # send out an email notifying user of bad charge
    AppMailer.delay.notify_on_failed_charge(user)

    Rails.logger.info "ChargeFailed: user: #{user}"
  end
end