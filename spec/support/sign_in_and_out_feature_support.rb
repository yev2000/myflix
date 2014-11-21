def sign_in_user_via_ui(email, password)
  visit sign_in_path
  fill_in "Email Address", with: email
  fill_in "Password", with: password
  click_button "Sign In"
end

def logout_user_via_ui
  page.find('#dlabel').click
  signout_link = find_link("Sign Out")
  signout_link.click
  expect(page).to have_content "Unlimited Movies"
  expect(page).to have_content "has logged out"
end

def expect_user_name_on_page(user)
  expect(page).to have_content user.fullname
end

