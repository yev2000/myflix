class UsersController < ApplicationController
  before_action :require_user, except: [:new, :create]
  before_action :set_user, only: [:show, :edit, :update]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    
    # we want to clear the danger flash before processing the below conditions
    # this is necessary because a prior execution may have set the danger flash
    # due to credit card errors, but user validation may not necessarily set the
    # danger flash (because we use in-line validation errors in the bootstrap form)
    # in which case stale info is in the flash.
    flash.delete(:danger)

    # we want to run both validations so cannot use them in a simple
    # && or || expression since both must fire...
    user_valid = @user.valid?
    password_confirmed = password_confirm!(@user, params[:user][:password], params[:user][:password_confirm])

    if user_valid && password_confirmed
      if(perform_payment(params[:stripeToken], params[:stripeEmail], User::REGISTRATION_COST_IN_CENTS) == true)
        perform_account_creation(@user, params[:invitation_token])
        redirect_to home_path
      else
        # we only set the danger flash if one has not already been set.
        # the perform_payment would set a flash if there was an error in
        # the credit card processing, so likely no need to add another
        # flash.  But just in case, we have this clause below.
        flash[:danger] = "Unable to create new user account because of a payment problem" if !flash[:danger]
        render :new
      end
    else
      # validation problem in the fields of the user even before
      # a charge is attempted
      # error should already be set on the object, so no extra flash danger is needed
      render :new
    end
  end # create

  def edit
  end

  def show
    @fresh_following = Following.new unless (@user.followers.include?(current_user) || @user == current_user)
  end

  def update
    input_password = params[:user][:password]

    # if password was supplied, then test for its validity
    if !valid_password_change_input(@user, input_password, params[:user][:password_confirm])
      render :edit
    elsif (@user.update(user_params) && @user.valid?)
      flash[:success] = "The account for \"#{@user.email}\" was updated."
      redirect_to user_path(@user)
    else
      render :edit
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :fullname)
  end

  def set_user
    @user = User.find_by(id: params[:id])
    if @user.nil? 
      flash[:danger] = "There is no user account for #{params[:id]}." 
      redirect_to root_path
    end
  end

  def handle_creation_from_invitation(newly_created_user, invitation_token)
    invitation = Invitation.find_by_token(invitation_token)
    if invitation
      newly_created_user.follow(invitation.user)
      invitation.user.follow(newly_created_user)
      Invitation.delete_invitations_by_email(invitation.email)
    end
  end

  def perform_payment(token, email, amount)
    response = StripeWrapper::Charge.create(amount: amount, card: token)
    return true if response.successful?
    
    flash[:danger] = "Error in processing your credit card (#{response.error_message})"
    return false
  end

  def perform_account_creation(user, invitation_token)
    user.save
    handle_creation_from_invitation(user, invitation_token)

    AppMailer.delay.notify_on_new_user_account(user)

    flash[:success] = "Your user account (for #{user.email}) was created.  You are logged in."

    # if we want to log the user in, we simply create
    # a session for the user implicitly.
    session[:userid] = user.id
  end

end
