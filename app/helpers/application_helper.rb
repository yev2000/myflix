module ApplicationHelper

  APP_VERSION = "0.3.0"

  def myflix_app_version
    APP_VERSION + " | " + BuildInfo.latest_build_string
  end
end
