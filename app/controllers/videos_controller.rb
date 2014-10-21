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
    end
  end

  def search
    # no need to check for nil, since search_by_title handles empty inputs
    @search_results = Video.search_by_title(params[:title_string])
  end

end
