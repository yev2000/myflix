class ReviewsController < AuthenticatedController
  before_action :set_video

  def create
    @review = Review.new(review_params)
    @review.video = @video
    @review.user = current_user

    if (@review.save)
      flash[:success] = "Your review for #{@video.title} has been recorded"
      redirect_to video_path(@video)
    else
      # error messages should already be set on the @review instance
      # if validations have failed.
      render "videos/show"
    end
  end

  def self.rating_choice_selection_options
    Review.rating_choices_string_array.inject([]) { |memo, str| memo << [str, str[0].to_i] }
  end

  private

  def set_video
    @video = Video.find_by(id: params[:video_id])
    if (@video.nil?)
      flash[:danger] = "There is no video with ID #{params[:video_id]}.  Showing all videos instead."
      redirect_to videos_path
    end
  end

  def review_params
    params.require(:review).permit(:title, :body, :rating)
  end

end
