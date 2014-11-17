require 'rails_helper'

feature "invite someone to MyFlix" do
  background do
    @inviter = Fabricate(:user, password: "pass", email: "svengali@svenco.com")
    clear_emails
  end

  scenario "user signs in and invites a friend, who then registers" do
    sign_in_user(@inviter)

    invitee_email = "jdoe@gmail.com"
    submit_invitation_request(@inviter, invitee_email)

    email_node = open_email(invitee_email)
    perform_invited_signup(email_node, @inviter, invitee_email)

    # visit people page to find that you follow the user who invited you
    click_link "People"
    leader_row = find_leader_row_in_people_table(@inviter)
    expect(leader_row).not_to be_nil
    expect(page).to have_content @inviter.fullname
  end

  scenario "user attempts to use invitation link twice" do
    sign_in_user(@inviter)

    # we invite someone to join MyFlix    
    invitee_email = "jdoe@gmail.com"
    submit_invitation_request(@inviter, invitee_email)

    # we then log out the inviter
    visit logout_path
    expect(page).to have_content "Unlimited Movies"
    expect(page).to have_content "has logged out"
   
    # the invitee performs a signup based upon the invitation email
    email_node = open_email(invitee_email)
    perform_invited_signup(email_node, @inviter, invitee_email)

    # the invitee then logs out   
    visit logout_path
    expect(page).to have_content "Unlimited Movies"
    expect(page).to have_content "has logged out"

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
    
    invitee_email = "jdoe@gmail.com"
    submit_invitation_request(@inviter, invitee_email)
    original_email_node = open_email(invitee_email)
    submit_invitation_request(@inviter, invitee_email)

    second_email_node = open_email(invitee_email)

    visit logout_path
    expect(page).to have_content "Unlimited Movies"
    expect(page).to have_content "has logged out"

    expect(original_email_node).not_to eq(second_email_node)

    perform_invited_signup(original_email_node, @inviter, invitee_email)

    second_email_node.click_link "Sign Up Here"
    expect(page).to have_content "Your invitation has expired or is not valid."
  end

end

def submit_invitation_request(user, invitee_email)
  visit new_invitation_path

  expect(page).to have_content "Invite a friend"
  fill_in "Friend's Name", with: "Jane Doe"
  fill_in "Friend's Email Address", with: invitee_email
  fill_in "Invitation Message", with: "Please join this great movie site!"

  click_button "Send Invitation"
  expect(page).to have_content "We have sent an invitation to #{invitee_email}"
end

def perform_invited_signup(email, inviter, invitee_email)
  email.click_link "Sign Up Here"
  expect(page).to have_content "Register"
  expect(page).to have_content "Invitation to register from #{inviter.fullname}"

  fill_in "Password", with: "pass"
  fill_in "Confirm Password", with: "pass"
  click_button "Sign Up"

  expect(page).to have_content "Your user account (for #{invitee_email}) was created. You are logged in."
end
