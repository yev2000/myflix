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

      # we set the @allow_add_queue variable based on whether the
      # selected video is in the current user's queue or not

      ### candidate for turning the below into an instance method of VideoQueueEntry
      if current_user_get.queued_videos.include? @video
        # video is already in user's queue, so we set the "allow_add_queue" to false, to prevent the
        # + My Queue button from being enabled.
        @video_queue_entry = nil
      else
        ### candidate for turning the below into a Class method of VideoQueueEntry
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

  def create_review
    @video = Video.find_by(id: params[:id])
    if (@video.nil?)
      flash[:danger] = "There is no video with ID #{params[:id]}.  Showing all videos instead."
      redirect_to videos_path
    else
      # the video being reviewed does exist.

      @review = Review.new(review_params)
      @review.video = @video
      @review.user = current_user_get
  
      if (@review.save)
        flash[:success] = "Your review for #{@video.title} has been recorded"
        redirect_to video_path(@video)
      else
        # error messages should already be set on the @review instance
        # if validations have failed.
        render :show
      end
    end
  end

  def review_params
    params.require(:review).permit(:title, :body, :rating)
  end


end
