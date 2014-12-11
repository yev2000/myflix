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

    password_confirmed = password_confirm!(@user, params[:user][:password], params[:user][:password_confirm])
    if !password_confirmed
      # error should already be set on the object, so no extra flash danger is needed
      render :new
    else
      result = UserCreation.new(@user,
        stripeToken: params[:stripeToken],
        invitation_token: params[:invitation_token]).create_user
      if result.successful?
        flash[:success] = "Your user account (for #{result.created_user.email}) was created.  You are logged in."

        # if we want to log the user in, we simply create
        # a session for the user implicitly.
        session[:userid] = result.created_user.id
        redirect_to home_path
      else
        flash[:danger] = result.error_message if result.error_message
        render :new
      end
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
end
