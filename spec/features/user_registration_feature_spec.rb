require "rails_helper"

feature "New user registers with credit card payment", { js: true, vcr: true } do
  before do
    visit root_path
    click_link "Sign Up Now!"
  end

  after do
    delete_stripe_customer_by_email("alice@aaa.com")
  end

  scenario "valid credit card and user information" do
    user_count_before_registration_attempt = User.count
    perform_signup_with_valid_credit_card "alice@aaa.com", "Alice Doe"
    expect(User.count).to eq(user_count_before_registration_attempt + 1)

    expect(page).to have_content "Your user account (for alice@aaa.com) was created. You are logged in."

    expect(page).to have_content User.find_by_email("alice@aaa.com").fullname
  end

  scenario "valid credit card and invalid email address" do
    Fabricate(:user, email: "alice@aaa.com")
    
    user_count_before_registration_attempt = User.count
    perform_signup_with_valid_credit_card "alice@aaa.com", "Alice Doe"
    expect(User.count).to eq(user_count_before_registration_attempt)
    
    expect(page).to have_content "Email has already been taken"
  end

  scenario "valid credit card and missing username" do
    user_count_before_registration_attempt = User.count
    perform_signup_with_valid_credit_card "alice@aaa.com", ""
    expect(User.count).to eq(user_count_before_registration_attempt)
    
    expect(page).to have_content "Fullname can't be blank"
  end

  scenario "valid credit card and missing email" do
    user_count_before_registration_attempt = User.count
    perform_signup_with_valid_credit_card "", "Alice Doe"
    expect(User.count).to eq(user_count_before_registration_attempt)
    
    expect(page).to have_content "Email can't be blank"
  end

  scenario "invalid credit card with valid user information" do
    user_count_before_registration_attempt = User.count    
    perform_signup_with_invalid_credit_card "alice@aaa.com", "Alice Doe"
    expect_invalid_card_flash
    expect(User.count).to eq(user_count_before_registration_attempt)
  end

  scenario "expired credit card with valid user information" do
    user_count_before_registration_attempt = User.count    
    perform_signup_with_expired_credit_card "alice@aaa.com", "Alice Doe"
    expect_expired_card_flash
    expect(User.count).to eq(user_count_before_registration_attempt)
  end

  scenario "declined credit card with valid user information" do
    user_count_before_registration_attempt = User.count
    perform_signup_with_declined_credit_card "alice@aaa.com", "Alice Doe"
    expect_declined_card_flash
    expect(User.count).to eq(user_count_before_registration_attempt)
  end

  scenario "invalid credit card with missing email" do
    user_count_before_registration_attempt = User.count    
    perform_signup_with_invalid_credit_card "", "Alice Doe"
    expect_invalid_card_flash
    expect(User.count).to eq(user_count_before_registration_attempt)
  end

  scenario "expired credit card with missing email" do
    user_count_before_registration_attempt = User.count    
    perform_signup_with_expired_credit_card "", "Alice Doe"
    expect(page).to have_content "Email can't be blank"
    expect(page).not_to have_content "Your card"
    expect(User.count).to eq(user_count_before_registration_attempt)
  end

  scenario "declined credit card with missing email" do
    user_count_before_registration_attempt = User.count
    perform_signup_with_declined_credit_card "", "Alice Doe"
    expect(page).to have_content "Email can't be blank"
    expect(page).not_to have_content "Your card"
    expect(User.count).to eq(user_count_before_registration_attempt)
  end

  scenario "invalid credit card with duplicate email" do
    Fabricate(:user, email: "alice@aaa.com")
    user_count_before_registration_attempt = User.count    
    perform_signup_with_invalid_credit_card "alice@aaa.com", "Alice Doe"
    expect_invalid_card_flash
    expect(User.count).to eq(user_count_before_registration_attempt)
  end

  scenario "expired credit card with duplicate email" do
    Fabricate(:user, email: "alice@aaa.com")
    user_count_before_registration_attempt = User.count    
    perform_signup_with_expired_credit_card "alice@aaa.com", "Alice Doe"
    expect(page).to have_content "Email has already been taken"
    expect(page).not_to have_content "Your card"
    expect(User.count).to eq(user_count_before_registration_attempt)
  end

  scenario "declined credit card with duplicate email" do
    Fabricate(:user, email: "alice@aaa.com")
    user_count_before_registration_attempt = User.count
    perform_signup_with_declined_credit_card "alice@aaa.com", "Alice Doe"
    expect(page).to have_content "Email has already been taken"
    expect(page).not_to have_content "Your card"
    expect(User.count).to eq(user_count_before_registration_attempt)
  end

end
