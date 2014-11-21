def set_current_user(user=nil)
  if user.nil?
    user = Fabricate(:user)
  end

  session[:userid] = user.id
end

def set_current_admin_user(user=nil)
  if user.nil?
    user = Fabricate(:admin)
  end

  session[:userid] = user.id
end

def spec_get_current_user
  User.find_by(id: session[:userid])
end

def clear_current_user
  session[:userid] = nil
end

def sign_in_user(user)
  visit sign_in_path
  fill_in "Email Address", with: user.email
  fill_in "Password", with: user.password
  click_button "Sign In"
end

def expect_danger_flash
  expect(flash[:danger]).not_to be_nil
end

def delete_s3_video_upload(video)
  if video
    if (video.large_cover && !video.large_cover_url.include?("no_image"))
      video.remove_large_cover!
    end

    if (video.small_cover && !video.small_cover_url.include?("no_image"))
      video.remove_small_cover!
    end
    
    video.save
  end
end
