class SessionsController < ApplicationController

  def new
    @login_email = nil
  end

  def create
    # here is where we authenticate the user
    user = User.find_by(email: params[:email]) if params[:email]

    if (user && user.authenticate(params[:password]))
      # the user was found so set the current user to this and
      # create the session
      session[:userid] = user.id

      flash[:notice] = "Welcome, #{user.email}!"

      # try to go where the user was originally going before they
      # hit the authentication challenge
      redirect_to_original_action
      clear_original_action
    else
      # create errors
      flash[:error] = "Invalid username or password"

      # save away the username that was entered so that when we
      # render the form again, we will preserve the contents of
      # the username entry field.  Saves the user time if they simply
      # mistyped their username.
      @login_email = params[:email]

      # re-render the login form so that they can re-enter the data.
      render :new
    end

  end

  def destroy
    flash[:notice] = "User #{current_user_get.username} logged out."
    
    session[:userid] = nil

    # is the following unnecessary since if @current_user is not cleared
    # in application_controller, it will have been cleared once the redirect
    # happens anyway.
    current_user_clear
    redirect_to root_path
  end

end
