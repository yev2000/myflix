class VideoQueueEntryController < ApplicationController
  before_action :require_user
  before_action :set_user
  before_action :require_current_user

  def index
    # we set up an instance variable to contain the array
    # of queued videos for the user in question
    # if no videos are queued, an empty array is created
    if @user.video_queue_entries.size == 0
      @queue_entries = []
    else
      @queue_entries = @user.video_queue_entries
    end

  end

  def create
    queue_entry = VideoQueueEntry.new(video_queue_params)
    queue_entry.user = @user

    # if position was omitted, make it the last entry for the user
    if queue_entry.position.nil?
      queue_entry.position = @user.video_queue_entries.size + 1
    end

    if (queue_entry.save)
      # success, so flash success message and display the queue
      flash[:success] = "Added #{queue_entry.video.title} to your queue."
      redirect_to my_queue_path
    else
      # something went wrong.  We don't have a form, so need to take the
      # errors off the errors object and place into a flash

      if queue_entry.video && @user.queued_videos.include?(queue_entry.video)
        # if the video being added was already in the user's queue, then redirect them to their "my queue" page
        flash[:danger] = "You already have this video in your queue"
        redirect_to my_queue_path
      else
        flash[:danger] = "Failed to add video to your queue"
        redirect_to home_path
      end
    end
  end

  private

  def set_user
    if params[:user_id]
      # if the ID was explicitly given, then use it to find the user
      @user = User.find_by(id: params[:user_id])
    elsif params[:video_queue_entry] && params[:video_queue_entry][:user_id]
      @user = User.find_by(id: params[:video_queue_entry][:user_id])
    else
      # if the user ID was not supplied, assume
      # that we are inquiring about the current (logged in) user's queue
      @user = current_user_get
    end
  end

  def require_current_user
    if (@user != current_user_get)
      # then someone is looking for the queue for a user other than
      # the currently logged in user.  We want to forbid that
      # unless later we add some "Admin" level functionality
      flash[:danger] = "You can only see your own queue.  You cannot view the queue for another user."
      return redirect_to home_path
    end
  end

  def video_queue_params
    params.require(:video_queue_entry).permit(:video_id, :user_id, :position)
  end


end
