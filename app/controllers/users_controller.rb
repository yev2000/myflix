class UsersController < ApplicationController
  before_action :require_user, except: [:new, :create, :email_reset_link, :confirm_password_reset, :reset_password, :update]
  before_action :require_user_or_reset_token, only: [:update]
  before_action :set_user, only: [:edit, :update]
  before_action :set_user_by_email, only: [:email_reset_link]
  before_action :set_user_by_token, only: [:reset_password]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    
    # we want to run both validations so cannot use them in a simple
    # && or || expression since both must fire...
    test1 = @user.valid?
    test2 = password_confirm!(@user)
    if (test1 && test2 && @user.save)

      AppMailer.notify_on_new_user_account(@user).deliver

      flash[:success] = "Your user account (for #{@user.email}) was created.  You are logged in."

      # if we want to log the user in, we simply create
      # a session for the user implicitly.
      session[:userid] = @user.id

      redirect_to home_path
    else
      render :new
    end

  end

  def edit
  end

  def update
    # if password was supplied, then set it
    if (password_confirm!(@user) && @user.update(user_params) && @user.valid?)
      # (will validations make sure duplicate username is not set?)
      flash[:success] = "The account for \"#{@user.email}\" was updated."
      redirect_to user_path(@user)
    else
      render :edit
    end

  end

  def email_reset_link
    @user.password_reset_token = SecureRandom.urlsafe_base64
    @user.save
    AppMailer.notify_password_reset(@user).deliver
    redirect_to confirm_password_reset_path
  end

  def reset_password
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :fullname)
  end

  def set_current_user
    @user = current_user_get
  end

  def set_user
    @user = User.find_by(id: params[:id])
    if @user.nil? 
      flash[:danger] = "There is no user account for #{params[:id]}." 
      redirect_to root_path
    end
  end

  def set_user_by_email
    @user = User.find_by_email(params[:email])
    if @user.nil?
      flash[:danger] = "There is no user account for with email #{params[:email]}"
      redirect_to sign_in_path
    end
  end

  def set_user_by_token
    @user = User.find_by_password_reset_token(params[:token])
    if @user.nil?
      flash[:danger] = "There is no user account for that password reset token"
      redirect_to root_path
    end
  end

  def password_confirm!(user)
    if (params[:user][:password] && (params[:user][:password] != params[:user][:password_confirm]))
      # user's password confirmation field did not match
      user.errors.add(:password_confirm, "Confirmation did not match.  Your password and password confirmation must match.")
      return false
    else
      return true
    end
  end

  def require_user_or_reset_token
    if (params[:user][:password_reset_token])
      if User.find_by_password_reset_token(params[:user][:password_reset_token]) != User.find_by_id(params[:id])
        flash[:danger] = "Invalid reset token specified"
        redirect_to root_path
      end
    else
      require_user
    end
  end
end
