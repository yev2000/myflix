class UserCreation

  attr_reader :error_message

  def initialize(user, options)
    @user = user
    @stripe_token = options[:stripeToken]
    @invitation_token = options[:invitation_token]
  end

  def create_user

    if @user.valid? && perform_subscription
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

  def perform_subscription

    customer_creation = CustomerCreation.new(@user, @stripe_token)
    response = customer_creation.create_customer
    if response.successful?
      return true
    else
      @error_message = "Error in setting up subscription (#{response.error_message})"
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
