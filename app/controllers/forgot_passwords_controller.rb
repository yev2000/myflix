class ForgotPasswordsController < ApplicationController
  before_action :set_user_by_email, only: [:create]
  before_action :set_user_by_token, only: [:reset_password, :update_password]

  def create
    @user.password_reset_token = SecureRandom.urlsafe_base64
    @user.save
    AppMailer.notify_password_reset(@user).deliver
    redirect_to confirm_password_reset_path
  end

  def update_password
    new_password = params[:password]

    # if password was supplied, then test for its validity
    if !valid_password_change_input(@user, new_password, params[:password_confirm])
      render :reset_password
    elsif (@user.update({ password: new_password }) && @user.valid?)
      @user.password_reset_token = nil
      @user.save

      flash[:success] = "Your password has been changed.  You can sign in with your new password now."

      redirect_to sign_in_path      
    else
      render :reset_password
    end

  end

  private

  def set_user_by_email
    if (!params[:email] || params[:email] == "")
      flash[:danger] = "Email cannot be blank"
      redirect_to forgot_password_path
    else
      @user = User.find_by_email(params[:email])
      if @user.nil?
        flash[:danger] = "There is no user account for with email #{params[:email]}"
        redirect_to forgot_password_path
      end
    end
  end

  def set_user_by_token
    @user = User.find_by_password_reset_token(params[:token]) if params[:token]
    if @user.nil?
      redirect_to invalid_password_reset_token_path
    end
  end

end
