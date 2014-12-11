class PaymentDecorator < Draper::Decorator
  delegate_all

  def charge_amount_string
    amount_in_cents = self.amount
    if (amount_in_cents > 0)
      return sprintf("$%.2f", amount_in_cents / 100.0)
    else
      return "No Charge"
    end
  end
end
