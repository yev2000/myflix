def click_video_image(video)
  video_selection = find(:xpath, "//a/img[@alt='#{video.title} (#{video.year.to_s})']/..")
  video_selection.click
end

def click_video_link(video)
  click_link video.title
end

def click_myflix_home
  click_link("MyFLiX")
end
