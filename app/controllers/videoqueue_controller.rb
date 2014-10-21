class VideoqueueController < ApplicationController
  before_action :require_user

  def index
    if params[:user_id].nil?
      # if the user ID was not supplied, assume
      # that we are inquiring about the current (logged in) user's queue
      @user = current_user_get
    else
      # if the ID was explicitly given, then use it to find the user
      @user = User.find_by(id: params[:user_id])
    end

    if (@user != current_user_get)
      # then someone is looking for the queue for a user other than
      # the currently logged in user.  We want to forbid that
      # unless later we add some "Admin" level functionality
      flash[:danger] = "You can only see your own queue.  You cannot view the queue for another user."
      return redirect_to home_path
    end

    # we set up an instance variable to contain the array
    # of queued videos for the user in question
    # if no videos are queued, an empty array is created
    if @user.video_queue_entries.size == 0
      @queue_entries = []
    else
      @queue_entries = @user.video_queue_entries
    end

  end

end
