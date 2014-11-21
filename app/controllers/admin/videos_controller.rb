class Admin::VideosController < AdminController
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

  private

  def video_params
    params.require(:video).permit(:title, :description, :cover, category_ids: [])
  end
end

