class FollowingsController < ApplicationController

  before_action :require_user

  def index
    @followings = current_user_get.following_relationships

  end

  def destroy
    @following = Following.find_by(id: params[:id])
    if @following.nil?
      flash[:danger] = "Attempt to delete non-existent follower/leader relationship"
    elsif @following.follower != current_user_get
      flash[:danger] = "You cannot remove a following relationship for a different user."
    else
      @following.destroy
    end
    
    redirect_to people_path
  end

end
