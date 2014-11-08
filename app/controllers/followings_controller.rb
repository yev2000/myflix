class FollowingsController < ApplicationController

  before_action :require_user

  def index
    @followings = current_user_get.followings

  end

end
