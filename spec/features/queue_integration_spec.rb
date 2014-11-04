require 'rails_helper'

feature "video queue management" do
  background do
    @user = Fabricate(:user)
    category = Fabricate(:category)
    4.times { Fabricate(:video, cover_small_url: "/tmp/forrest_gump_small.PNG", categories: [category]) }
  end

  scenario "user adds and reorders queue items after signing in" do
    # first log in
    sign_in_user(@user)
    expect_user_name_on_page(@user)
    
    # then visit the videos page by clicking on the link for a video
    click_video_image(Video.first)
    # make sure we got to the show page, which will have
    # the video title and description visible
    expect_video_details(Video.first)

    # and add that video to the user's queue
    expect_button_exists("+ My Queue")

    click_add_to_queue

    # this should deliver us to the page with the queue
    # so we should expect a form row for that item
    # and confirm that the other videos in the system don't appear
    expect_queue_page_with_videos([Video.first], (2..4).map { |n| Video.find(n) } ) 
    
    # click on that video to see its details
    click_video_link Video.first

    # make sure we got to the show page, which will have
    # the video title and description visible
    expect_video_details(Video.first)
    
    # if the video is in the user's queue, the button to add to the
    # queue will not be present, while the button-like link to
    # show the user queue will be available
    expect(page).not_to have_button "+ My Queue"
    expect(page).to have_link "Show My Queue"

    # Now we need to go to the home page and add a few more videos
    # to the user's queue
    add_video_to_queue(Video.find(2))
    add_video_to_queue(Video.find(3))
    add_video_to_queue(Video.find(4))

    # now that all 4 videos are in the user's queue, let's
    # confirm they are all listed on that page in the proper order
    expect_queue_page_with_videos([Video.find(1), Video.find(2), Video.find(3), Video.find(4)])

    # now let's re-arrange the order
    new_order = [Video.find(3), Video.find(2), Video.find(4), Video.find(1)]
    set_queue_video_order(new_order)

    # now submit the change
    click_update_queue
    
    # and confirm new ordering
    expect_queue_page_with_videos(new_order)
  end
end

def expect_user_name_on_page(user)
  expect(page).to have_content user.fullname
end

def expect_video_details(video)
  expect(page).to have_content video.title
  expect(page).to have_content video.description
end

def expect_button_exists(button_text)
  expect(page).to have_button button_text
end

def expect_queue_page_with_videos(videos_existing, videos_not_existing=[])
  expect(page).to have_content "List Order"
  videos_existing.each_with_index do |video, index|
    expect(page).to have_link video.title
    expect(find(:xpath, "//tr[contains(.,'#{video.title}')]//input[@type='text']").value).to eq((index+1).to_s)
  end

  videos_not_existing.each do |video|
    expect(page).not_to have_link video.title
  end
end
