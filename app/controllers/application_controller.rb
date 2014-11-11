class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_user, :logged_in?

  ########################
  #
  # Redirection
  #
  ########################

  def redirect_to_original_action
    # the user was going somewhere before being intercepted,
    # then send them there now.  Otherwise, we direct to the
    # home path.
    if session[:prior_url]
      redirect_to session[:prior_url]
      session[:prior_url] = nil
    else
      redirect_to home_path
    end
  end

  ########################
  #
  # User Management
  #
  ########################

  def current_user
    @current_user ||= User.find_by(id: session[:userid]) if session[:userid]
  end

  def logged_in?
    !!(current_user)
  end

  def current_user_clear
    @current_user = nil
  end

  def require_user
    if !logged_in?
      flash[:danger] = "Must be logged in to do this"
      session[:prior_url] = request.get? ? request.path : nil
      redirect_to sign_in_path
    else
      session[:prior_url] = nil
    end
  end
end
