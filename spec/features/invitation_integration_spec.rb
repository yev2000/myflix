require 'rails_helper'

feature "invite someone to MyFlix", {js: true, vcr: true} do
  background do
    @inviter = Fabricate(:user, password: "pass", email: "svengali@svenco.com")
    clear_emails
  end

  after do
    clear_emails
    delete_stripe_customer_by_email("an_invited_address@sample.com")
  end

  scenario "demonstrate capybara logout issue" do
    # generate an invitation instance. The "inviter" is alice
    grace = Fabricate(:user, fullname: "Grace Hopper")
    invitation = Fabricate(:invitation, fullname: "Alan Turing", user: grace, email: "an_invited_address@sample.com")

    # mail out the invitation
    retval = AppMailer.notify_invitation(invitation).deliver

    email_node = open_email(invitation.email)

    # let the user sign in
    perform_invited_signup_with_valid_credit_card(email_node, grace, invitation.email)

    # at this point we expect the invited user to have been logged in
    expect(page).to have_content "Your user account (for #{invitation.email}) was created. You are logged in."

    # now the fun part - we try to log out the user via visiting the logout path
    visit logout_path

    # the above will not work; but if instead you use the below line, it will work
    # logout_user_via_ui
  end


  scenario "user signs in and invites a friend, who then registers" do
    sign_in_user(@inviter)

    invitee_email = "an_invited_address@sample.com"
    submit_invitation_request(@inviter, invitee_email)
    logout_user_via_ui # logs out inviter

    email_node = open_email(invitee_email)
    perform_invited_signup_with_valid_credit_card(email_node, @inviter, invitee_email)

    # make sure the new user if following the user who invited them
    confirm_following_relationship(@inviter)
    logout_user_via_ui

    # log in as the inviter and see that you're following your invitee
    sign_in_user(@inviter)
    confirm_following_relationship(User.find_by_email(invitee_email))
  end

  scenario "user attempts to use invitation link twice" do
    sign_in_user(@inviter)

    invitee_email = "an_invited_address@sample.com"
    submit_invitation_request(@inviter, invitee_email)

    # the inviter then logs out
    logout_user_via_ui 

    # the invitee performs a signup based upon the invitation email
    email_node = open_email(invitee_email)
    perform_invited_signup_with_valid_credit_card(email_node, @inviter, invitee_email)

    # the invitee then logs out   
    logout_user_via_ui

    # now we try to follow the link that was in the invitation email
    # to try to register again
    email_node.click_link "Sign Up Here"

    expect(page).to have_content "Your invitation has expired or is not valid."
    expect(page).to have_content "Sign In"
    expect(page).not_to have_content "People"
    expect(page).not_to have_content "Search"
    expect(page).not_to have_content "Jane Doe"
  end

  scenario "user attempts to use an invitation after already having registered their email address" do
    sign_in_user(@inviter)
    
    invitee_email = "an_invited_address@sample.com"
    submit_invitation_request(@inviter, invitee_email)
    original_email_node = open_email(invitee_email)
    submit_invitation_request(@inviter, invitee_email)
    second_email_node = open_email(invitee_email)
    logout_user_via_ui

    expect(original_email_node).not_to eq(second_email_node)

    perform_invited_signup_with_valid_credit_card(original_email_node, @inviter, invitee_email)

    second_email_node.click_link "Sign Up Here"
    expect(page).to have_content "Your invitation has expired or is not valid."
  end
end

def submit_invitation_request(user, invitee_email)
  page.find('#dlabel').click
  find_link("Invite a friend").click

  expect(page).to have_content "Invite a friend"
  fill_in "Friend's Name", with: "Jane Doe"
  fill_in "Friend's Email Address", with: invitee_email
  fill_in "Invitation Message", with: "Please join this great movie site!"

  click_button "Send Invitation"
  expect(page).to have_content "We have sent an invitation to #{invitee_email}"
end

def confirm_following_relationship(leader)
  click_link "People"
  leader_row = find_leader_row_in_people_table(leader)
  expect(leader_row).not_to be_nil
  expect(page).to have_content leader.fullname
end
