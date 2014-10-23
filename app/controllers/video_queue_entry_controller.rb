class VideoQueueEntryController < ApplicationController
  before_action :require_user
  before_action :set_user
  before_action :require_current_user

  def index
    # we set up an instance variable to contain the array
    # of queued videos for the user in question
    # if no videos are queued, an empty array is created
    @queue_entries = @user.sorted_video_queue_entries
  end

  def create
    queue_entry = VideoQueueEntry.new(video_queue_params)

    # the "owner" of the queue item is the user that was set in the before_action filter.
    queue_entry.user = @user

    # if position was omitted, make it the last entry for the user
    # really, this code has not yet been written to handle the case of
    # arbitrary positions and "shifting" of sibling queue items to accommodate
    # a position that overlaps with any existing queue entry
    if queue_entry.position.nil?
      queue_entry.position = @user.video_queue_entries.size + 1
    end

    if (queue_entry.save)
      # success, so flash success message and display the user's queue
      flash[:success] = "Added #{queue_entry.video.title} to your queue."
      redirect_to my_queue_path
    else
      # something went wrong.  We don't have a form, so need to take the
      # errors off the errors object and place into a flash
      
      ### This code (to take errors from the object and place in a flash message) has
      ### not been implemented.

      # we happen to handle the very special case of attempting to add a video
      # that is already in the queue:
      if queue_entry.video && @user.queued_videos.include?(queue_entry.video)
        # if the video being added was already in the user's queue, then redirect them to their "my queue" page
        flash[:danger] = "You already have #{queue_entry.video.title} in your queue"
        redirect_to my_queue_path
      else
        flash[:danger] = "Failed to add video to your queue"
        redirect_to home_path
      end
    end
  end

  def destroy
    @queue_entry = VideoQueueEntry.find_by(id: params[:id])
    if @queue_entry.nil?
      # we did not find the queue entry - so this is an error condition
      flash[:danger] = "No queued video has an ID of #{params[:id]}."
    elsif @queue_entry.user != @user
      # the queue entry exists, but is owned by a user different than the current user
      # this is also an error condition
      flash[:danger] = "Editing a different user's video queue is not allowed."
    else
      # try to destroy the record that the user tried to remove
      @queue_entry.destroy

      # and re-sequence the remaining videos in the user's queue so that they are in order and "tight"
      if adjust_positions(@user.video_queue_entries)
        flash[:success] = "Removed #{@queue_entry.video.title} from the queue."
      else
        # should not ever happen but we catch this case here
        flash[:danger] = "Unable to adjust positions of queue items."
      end
    end

    # in all cases, error or success - we redirect to the current user's video queue
    redirect_to my_queue_path
  end

  def update
    replacement_array = []

    # now as a result of position value changes, we may the queue elements not starting at the 1 position
    # so let's sort the array by position and renumber
    VideoQueueEntry.transaction do
      params[:video_queue_entry].each do |key,value|
        vqe = VideoQueueEntry.find_by(id: key)
        if (vqe)
          # queue entry ids that are passed in must all belong to the passed in user (or current_user if user_id was not supplied)
          if vqe.user != @user
            flash[:danger] = "Video queue positions cannot be provided for a different user's queue."
            raise ActiveRecord::Rollback 
          end

          vqe.position = value.to_i

          # if the position is < 1, this means that the parameter value is either not representing a number
          # or is a zero or negative value.  We will reject all of these
          if vqe.position < 1
            flash[:danger] = "Queue positions must be specified as integers, 1 or larger"
            raise ActiveRecord::Rollback 
          end
          
          replacement_array << vqe
        end
      end

      # if the array size does not match the user's queue, then we have supplied too many or too few
      # entries
      if replacement_array.size != @user.video_queue_entries.size
        if replacement_array.size < @user.video_queue_entries.size
          flash[:danger] = "Some position values for videos in the queue were not provided."
        elsif replacement_array.size > @user.video_queue_entries.size
          flash[:danger] = "Positions for one or more videos were provided more than once."
        end

        raise ActiveRecord::Rollback 
      end

      # now that we know the array contains only the relevant user's entries,
      # we need to sort it so that we can renumber it starting from 1, but also
      # to make sure that no duplicate positions are being supplied
      replacement_array.sort! do |x,y|
        if (x.position == y.position)
          flash[:danger] = "You cannot give the same position to more than one video.  \
            Videos #{x.video.title} and #{y.video.title} were given the same position."
          raise ActiveRecord::Rollback
        end

        x.position <=> y.position
      end

      # and let's renumber starting at 1 (this is to handle the case that some ID
      # was moved to the end of the array from the front or middle without other
      # positions being renumbered by the user)
      replacement_array.each_with_index { |vqe, index | vqe.position = index+1 }

      # finally once all new position values are defined, we commit to the database
      # because this is wrapped in a transaction, if any problems occur, we will
      # be able to roll everything back.
      replacement_array.each do |vqe|
        vqe.save
      end
    end

    redirect_to my_queue_path
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
      flash[:danger] = "You can only see and edit your own queue.  You cannot view or edit the queue for another user."
      return redirect_to home_path
    end
  end

  def video_queue_params
    params.require(:video_queue_entry).permit(:video_id, :user_id, :position)
  end

  def adjust_positions(video_queue_entry_array)
    # renumber the position values of the videos in the array that is
    # passed in.  It is expected that the order of the videos in the array
    # is the intended "positional" order.
    video_queue_entry_array.each_with_index do |entry, index|
      entry.position = index + 1
      if (entry.save == false)
        return false
      end
    end

    return true
  end

end
