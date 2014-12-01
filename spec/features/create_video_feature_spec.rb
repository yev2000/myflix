require 'rails_helper'

feature "create video" do
  background do
    @admin_user = Fabricate(:admin)
    @regular_user = Fabricate(:user)
    @category = Fabricate(:category)
  end

  after do
    delete_s3_video_upload(Video.find_by_title("Batman"))
  end

  scenario "admin user creates a new video with file upload for cover art", :vcr do
    # first log in
    sign_in_user(@admin_user)
    expect_user_name_on_page(@admin_user)

    admin_add_new_video("Batman", @category, "A superhero movie",
      "https://s3.amazonaws.com/myflix-yev/test/another+example.mp4",
      Rails.root + "spec/support/attachments/monk_large.jpg",
      Rails.root + "spec/support/attachments/monk_small.jpg")
  end  

  scenario "admin user creates a new video, and regular user navigates to the video details and can select to watch it", :vcr do
    sign_in_user(@admin_user)

    admin_add_new_video("Batman", @category, "A superhero movie",
      "https://s3.amazonaws.com/myflix-yev/test/another+example.mp4",
      Rails.root + "spec/support/attachments/monk_large.jpg",
      Rails.root + "spec/support/attachments/monk_small.jpg")

    # admin then logs out
    logout_user_via_ui

    # regular user signs in 
    sign_in_user(@regular_user)

    # that user selects a particular video
    click_video_image(Video.first)
    expect(page).to have_content "Batman"

    click_link "Watch Now"
    expect(page).to have_xpath("//source[contains(@src, \"another+example.mp4\")]")
  end
end

def admin_add_new_video(title, category, description, video_url, large_cover_file_path, small_cover_file_path)
  click_link "Add Video"
  expect(page).to have_content "Add a New Video"

  fill_in "Title", with: title
  fill_in "Description", with: description
  fill_in "Video url", with: video_url
  select category.name, from: "Categories"
  attach_file "video_large_cover", large_cover_file_path
  attach_file "video_small_cover", small_cover_file_path

  click_button "Add Video"

  expect(page).to have_content title
  expect(page).to have_content description
  expect(page).to have_content "Rate this video"
  expect(page).to have_content "User Reviews"
  expect(page).to have_xpath("//img[contains(@src, \"#{large_cover_file_path.basename.to_s}\")]")
end
