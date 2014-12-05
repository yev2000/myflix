class UserCreation

  attr_reader :error_message

  def initialize(user, options)
    @user = user
    @stripe_token = options[:stripeToken]
    @invitation_token = options[:invitation_token]
  end

  def create_user

    if @user.valid? && perform_payment
      if @user.save != false
        @created_user = @user 
      end
      
      handle_creation_from_invitation

      AppMailer.delay.notify_on_new_user_account(@user)

      @creation_success = true
    else
      @creation_success = false
    end

    return self
  end

  def successful?
    @creation_success
  end

  def created_user
    @created_user
  end

  private

  def perform_payment
    response = StripeWrapper::Charge.create(amount: User::REGISTRATION_COST_IN_CENTS, card: @stripe_token)
    if response.successful?
      return true
    else
      @error_message = "Error in processing your credit card (#{response.error_message})"
      return false
    end
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
