class UsersController < ApplicationController
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
      flash[:notice] = "Your user account (for #{@user.email}) was created.  You are logged in."

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
      flash[:notice] = "There is no user account for #{params[:id]}." 
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
