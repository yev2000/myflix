class FollowingsController < AuthenticatedController
  def index
    @followings = current_user.following_relationships
  end

  def create
    leader = User.find_by(id: params[:user_id])

    case
    when leader.nil?
      flash[:danger] = "Attempt to follow a user who does not exist"
    when leader == current_user
      flash[:danger] = "You cannot follow yourself"
    when current_user.follows?(leader)
      flash[:danger] = "You are already following the user #{leader.fullname}"
    else
      Following.create(leader_id: leader.id, follower_id: current_user.id)
    end

    redirect_to people_path

  end

  def destroy
    following = Following.find_by(id: params[:id])
    if following.nil?
      flash[:danger] = "Attempt to delete non-existent follower/leader relationship"
    elsif following.follower != current_user
      flash[:danger] = "You cannot remove a following relationship for a different user."
    else
      following.destroy
    end
    
    redirect_to people_path
  end

end
