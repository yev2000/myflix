require 'rails_helper'

feature "create video" do
  background do
    @admin_user = Fabricate(:admin)
    @category = Fabricate(:category)
  end

  after do
    delete_s3_video_upload(Video.find_by_title("Batman"))
  end

  scenario "user creates a new video with file upload for cover art" do
    # first log in
    sign_in_user(@admin_user)
    expect_user_name_on_page(@admin_user)

    visit new_admin_video_path

    expect(page).to have_content "Add a New Video"
    fill_in_new_video_form("Batman", @category, "A superhero movie", Rails.root + "spec/support/attachments/monk.jpg")

    expect(page).to have_content "Batman"
    expect(page).to have_content "Rate this video"
    expect(page).to have_xpath("//img[contains(@src, \"monk.jpg\")]")
    expect(page).to have_content "User Reviews"
  end  
end

def fill_in_new_video_form(title, category, description, file_path)
  fill_in "Title", with: title
  fill_in "Description", with: description
  select category.name, from: "Categories"
  attach_file "video_cover", file_path

  click_button "Add Video"
end
