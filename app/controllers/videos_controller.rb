class VideosController < ApplicationController
  before_action :require_user

  def index
    @categories = Category.all
  end

  def show
    @video = Video.find(params[:id])
  end

  def search
    # no need to check for nil, since search_by_title handles empty inputs
    @search_results = Video.search_by_title(params[:title_string])
  end

end
