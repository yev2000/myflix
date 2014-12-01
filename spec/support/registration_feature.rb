def perform_signup(credit_card_number, options={})
  expect(page).to have_content "Register"

  fill_in "Email Address", with: options[:new_user_email] if options[:new_user_email]
  fill_in "Full Name", with: options[:new_user_name] if options[:new_user_name]

  fill_in "Password", with: "pass"
  fill_in "Confirm Password", with: "pass"
  fill_in "Credit Card Number", with: credit_card_number
  fill_in "Security Code", with: "123"
  select "7 - July", from: "date_month"
  select "2016", from: "date_year"
  
  click_button "Pay and Sign Up"
  sleep(1)
end

def perform_invited_signup_with_valid_credit_card(email, inviter, invitee_email)
  email.click_link "Sign Up Here"
  expect(page).to have_content "Invitation to register from #{inviter.fullname}"

  # note, we don't need to pass any options to perform_signup because
  # a signup page coming from an invitation will pre-fill the email address
  # and username fields
  perform_signup "4242424242424242"

  expect(page).to have_content "Your user account (for #{invitee_email}) was created. You are logged in."
end

def perform_signup_with_valid_credit_card(new_user_email, new_user_name)
  perform_signup "4242424242424242", { new_user_email: new_user_email, new_user_name: new_user_name}
end

def perform_signup_with_expired_credit_card(new_user_email, new_user_name)
  perform_signup "4000000000000069", { new_user_email: new_user_email, new_user_name: new_user_name}
end

def perform_signup_with_invalid_credit_card(new_user_email, new_user_name)
  perform_signup "456", { new_user_email: new_user_email, new_user_name: new_user_name}
end

def perform_signup_with_declined_credit_card(new_user_email, new_user_name)
  perform_signup "4000000000000002", { new_user_email: new_user_email, new_user_name: new_user_name}
end

def expect_expired_card_flash
  expect(page).to have_content "Error in processing your credit card"
  expect(page).to have_content "Your card has expired"
end

def expect_invalid_card_flash
  expect(page).to have_content "looks invalid"
end

def expect_declined_card_flash
  expect(page).to have_content "Error in processing your credit card"
  expect(page).to have_content "Your card was declined"
end
