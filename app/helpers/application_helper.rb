module ApplicationHelper

  APP_VERSION = "0.2.1"

  def myflix_app_version
    build_date_string = ENV['MYFLIX_BUILD_DATE'] ? " -- " + ENV['MYFLIX_BUILD_DATE'] : "  Development or Test build"
    APP_VERSION + build_date_string
  end
end
