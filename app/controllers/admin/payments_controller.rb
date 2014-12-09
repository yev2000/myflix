class Admin::PaymentsController < AdminController
  def index
    @payments = Payment.all
  end

  def create
    binding.pry
    redirect_to admin_payments_path
  end

end
