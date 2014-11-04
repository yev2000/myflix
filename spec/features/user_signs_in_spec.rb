require 'rails_helper'


feature "user signs in" do
  background do
    Fabricate(:user, email: "alice@aaa.com", fullname: "Alice Doe", password: "pass")
  end
  
  scenario "valid account email and password" do
    visit sign_in_path
    fill_in "Email Address", with: "alice@aaa.com"
    fill_in "Password", with: "pass"
    click_button "Sign In"
    expect(page).to have_content "Alice Doe"
  end

  scenario "valid account email and invalid password" do
    visit sign_in_path
    fill_in "Email Address", with: "alice@aaa.com"
    fill_in "Password", with: "passAAA"
    click_button "Sign In"
    expect(page).to have_content "Invalid email or password"
    expect(page).to have_field("Email Address", with: "alice@aaa.com")
  end

  scenario "invalid account email" do
    visit sign_in_path
    fill_in "Email Address", with: "bob@bbb.com"
    fill_in "Password", with: "pass"
    click_button "Sign In"
    expect(page).to have_content "Invalid email or password"
    expect(page).to have_field("Email Address", with: "bob@bbb.com")
  end

  scenario "missing password" do
    visit sign_in_path
    fill_in "Email Address", with: "alice@aaa.com"
    click_button "Sign In"
    expect(page).to have_content "Invalid email or password"
    expect(page).to have_field("Email Address", with: "alice@aaa.com")

  end
  
end

