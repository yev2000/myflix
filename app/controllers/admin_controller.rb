class AdminController < AuthenticatedController
  before_action :require_admin_user


  def require_admin_user
    if !(logged_in? && current_user.admin?)
      flash[:danger] = "Must be logged in as an admin to do this"
      redirect_to sign_in_path
    end
  end
end
