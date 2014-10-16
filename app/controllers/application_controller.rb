class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_user_get, :logged_in?

  ########################
  #
  # Redirection
  #
  ########################

  def clear_original_action
    session[:prior_url] = nil
  end

  def redirect_to_original_action
    # the user was going somewhere before being intercepted,
    # then send them there now.  Otherwise, we direct to the
    # home path.
    if session[:prior_url]
      redirect_to session[:prior_url]
      clear_original_action
    else
      redirect_to home_path
    end
  end

  ########################
  #
  # User Management
  #
  ########################

  def current_user_get
    @current_user ||= User.find(session[:userid]) if session[:userid]
  end

  def logged_in?
    !!(current_user_get)
  end

  def current_user_clear
    @current_user = nil
  end

  def require_user
    if !logged_in?
      flash[:danger] = "Must be logged in to do this"

      ## is there a way to know what the current path is, so
      ## that once we've logged in we can redirect to there?
      ## after having been redirecte to the login?
      session[:prior_url] = request.get? ? request.path : nil
      
      redirect_to sign_in_path
    else
      clear_original_action
    end
  end

end
