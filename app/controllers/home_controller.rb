class HomeController < ApplicationController

  def index
    @categories = Category.all
  end

  def front
  end

  def register
    redirect_to new_user_path
  end

end
