class UsersController < ApplicationController
  before_action :require_user, except: [:new, :create]
  before_action :set_user, only: [:edit, :update]

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


  private

  def user_params
    params.require(:user).permit(:email, :password, :fullname)
  end

  def set_current_user
    @user = current_user_get
  end

  def set_user
    @user = User.find(params[:id])
    if @user.nil? 
      flash[:danger] = "There is no user account for #{params[:id]}." 
      redirect_to front_path
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

end
