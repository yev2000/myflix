def set_current_user(user=nil)
  if user.nil?
    user = Fabricate(:user)
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


####################
#
# Features
#
####################

def click_video_image(video)
  video_selection = find(:xpath, "//a/img[@alt='#{video.title} (#{video.year.to_s})']/..")
  video_selection.click
end

def click_video_link(video)
  click_link video.title
end

def click_add_to_queue
  click_button "+ My Queue"
end

def add_video_to_queue(video)
  click_myflix_home
  click_video_image(video)
  click_add_to_queue
end

def click_myflix_home
  click_link("MyFLiX")
end

def click_update_queue
  click_button "Update Instant Queue"
end

def set_queue_video_order_low_level(new_order)
  # this is no longer used, once we added the
  # data-video-id-<#> to the input field in
  # the queue template
  all("tr").each_with_index do |row_node, index|
    if (index > 0)
      moved_video = Video.find(index)
      row_node.all("input")[0].set (new_order.index(moved_video) + 1).to_s
    end
  end
end

def check_queue_rows_low_level
  # this is no longer used, but here for reference in terms
  # of a low-level implementation that is brittle and does not use
  # xpath effectively
  all("tr").each_with_index do |row_node, index|
    if (index > 0)
      expect(row_node.all("input")[0].value).to eq(index.to_s)
      expect(row_node.all("a")[0].text).to eq(Video.find(index).title)
    end
  end
end

def set_queue_video_order(new_order)
  new_order.each_with_index do |video, index|
    find("input[data-video-id='#{video.id}']").set((index + 1).to_s)
  end
end
