class UserCreation

  def initialize(user, flash_handler, options)
    @user = user
    @stripe_token = options[:stripeToken]
    @invitation_token = options[:invitation_token]
    @flash_handler = flash_handler
  end

  def create_user
    return false if !perform_payment

    @user.save
    handle_creation_from_invitation

    AppMailer.delay.notify_on_new_user_account(@user)
    return true
  end

  private

  def perform_payment
    response = StripeWrapper::Charge.create(amount: User::REGISTRATION_COST_IN_CENTS, card: @stripe_token)
    return true if response.successful?
    
    @flash_handler.set_flash(:danger, "Error in processing your credit card (#{response.error_message})")
    return false
  end

  def handle_creation_from_invitation
    invitation = Invitation.find_by_token(@invitation_token)
    if invitation
      @user.follow(invitation.user)
      invitation.user.follow(@user)
      Invitation.delete_invitations_by_email(invitation.email)
    end
  end

end
