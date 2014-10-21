class ReviewsController < ApplicationController
  before_action :require_user

  def create
    @video = Video.find_by(id: params[:video_id])
    if (@video.nil?)
      flash[:danger] = "There is no video with ID #{params[:video_id]}.  Showing all videos instead."
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
