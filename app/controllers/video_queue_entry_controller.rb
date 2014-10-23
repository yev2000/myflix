require Rails.root.to_s + "/lib/myflix_exception"

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
      if VideoQueueEntry.renumber_positions!(@user.video_queue_entries)
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
    # Make changes to the positions of items in the user's video queue by
    # processing the submitted post parameters.  The post parameters will contain
    # a mapping of video queue entry ID to new position value.
    begin
      mapping_array = validate_position_update_parameters(params[:video_queue_entry])
      VideoQueueEntry.update_queue_positions!(mapping_array) if mapping_array
    rescue QueuePositionError => exception_val
      flash[:danger] = exception_val.message
    end

    redirect_to my_queue_path
  end

  private

  def validate_position_parameter_string(parameter_input_string)
    new_position_value = parameter_input_string.to_i

    # if the position is < 1, this means that the parameter value is either not representing a number
    # or is a zero or negative value.  We will reject all of these
    return nil if new_position_value < 1
    new_position_value
  end

  def check_for_entry_completeness(mapping_array)
    # if the array size does not match the user's queue, then we have supplied too many or too few
    # entries
    case
    when mapping_array.length < @user.video_queue_entries.size
      raise QueuePositionError, "Some position values for videos in the queue were not provided."
    when mapping_array.length > @user.video_queue_entries.size
      raise QueuePositionError, "Positions for one or more videos were provided more than once."
    end

    return false
  end

  def validate_position_update_parameters(id_to_position_mapping_params)
    validated_mapping_array = []

    id_to_position_mapping_params.each do |queue_entry_id,position_string|
      vqe = VideoQueueEntry.find_by(id: queue_entry_id)

      # this is the case when an entry ID is invalid
      return nil if vqe.nil?

      # queue entry ids that are passed in must all belong to the passed in user
      # (or current_user if user_id was not supplied)
      raise(QueuePositionError, "Video queue positions cannot be provided for a different user's queue.") unless vqe.user == @user

      # make sure position value that is being input in the parameters is
      # a valid number that is greater than 0
      new_position_value = validate_position_parameter_string(position_string)
      raise(QueuePositionError, "Queue positions must be specified as integers, 1 or larger") if new_position_value.nil?

      # finally if all is well, accumulate the queue_entry to position mapping
      validated_mapping_array << {entry: vqe, new_position: new_position_value}
    end

    # we need to confirm that all IDs for the user's queue were provided.
    # If any were omitted or provided more than once, that is an error
    check_for_entry_completeness(validated_mapping_array)

    return validated_mapping_array
  end

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

end


#if (<VideoQueueEntry.transaction do> { stuff }  == <success>)
#  flash[:success] = "OK!"
#else
#  flash [:danger] = "Tx failed!"
#end
