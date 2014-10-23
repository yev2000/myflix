class VideosController < ApplicationController
  before_action :require_user

  def index
    @categories = Category.all
  end

  def show
    begin
      @video = Video.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      flash[:danger] = "There is no video with ID #{params[:id]}.  Showing all videos instead."
      redirect_to videos_path
    end

    if (@video)
      # sets the review instance variable to a new(blank) review if
      # the logged in user has not yet reviewed the video
      if @video.reviews.find_by(user_id: current_user_get.id)
        @review = nil
      else
        @review = Review.new
      end

      # we set @video_queue_entry based on whether the
      # selected video is in the current user's queue or not

      ### REFACTOR candidate for turning the below into an instance method of VideoQueueEntry
      if current_user_get.queued_videos.include? @video
        
        # video is already in user's queue, so we set the instance variable to nil, to prevent the
        # + My Queue button from being displayed.
        @video_queue_entry = nil
      else
        ### REFACTOR candidate for turning the below into a Class method of VideoQueueEntry
        @video_queue_entry = VideoQueueEntry.new(
          position: current_user_get.queued_videos.size + 1, # position is at the end of the queue
          user_id: current_user_get.id,
          video_id: @video.id)
      end
    end
  end

  def search
    # no need to check for nil, since search_by_title handles empty inputs
    @search_results = Video.search_by_title(params[:title_string])
  end

end
