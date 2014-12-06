class Admin::VideosController < AdminController
  before_action :set_video, only: [:edit, :update]

  def new
    @video = Video.new
  end

  def create
    @video = Video.new(video_params)
    if @video.save
      flash[:success] = "The video (#{@video.title} has been created."
      redirect_to video_path(@video)
    else
      flash[:danger] = "Error saving the video"
      render :new
    end
  end

  def edit
  end

  def update
    if (@video.update(video_params) && @video.valid?)
      flash[:success] = "The Video \"#{@video.title}\" was updated."
      redirect_to video_path(@video)
    else
      render :edit
    end
  end

  private

  def video_params
    params.require(:video).permit(:title, :description, :video_url, :large_cover, :small_cover, :movie_file, category_ids: [])
  end

  def set_video
    @video = Video.find_by(id: params[:id])
    if (@video.nil?)
      flash[:danger] = "There is no video with ID #{params[:id]}."
      redirect_to home_path
    end

  end

end

