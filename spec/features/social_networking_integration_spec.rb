require 'rails_helper'

feature "social networking" do
  background do
    @alice = Fabricate(:user, email: "alice@aaa.com", fullname: "Alice Doe", password: "pass")
    @bob = Fabricate(:user, email: "bob@bbb.com", fullname: "Bob Doe")
    @charlie = Fabricate(:user, email: "charlie@ccc.com", fullname: "Charlie Doe")

    category = Fabricate(:category)
    @star_wars = Fabricate(:video, categories: [category])
    @usual_suspects = Fabricate(:video, categories: [category])
    @jaws = Fabricate(:video, categories: [category])

    Fabricate(:review, video: @star_wars, user: @bob)
    Fabricate(:review, video: @usual_suspects, user: @charlie)
    Fabricate(:review, video: @jaws, user: @alice)
  end

  scenario "user alice follows user bob, unfollows, and refollows him" do
    sign_in_user_via_ui(@alice.email, "pass")

    follow_leader_who_reviewed_movie(@star_wars, @bob)

    # should take us to people page
    expect(page).to have_content "People I Follow"

    # should list Bob Doe in a row in the listing
    leader_row = find_leader_row_in_people_table(@bob)
    expect(leader_row).not_to be_nil

    # unfollow bob
    unfollow_link = find_unfollow_link_in_leader_row(leader_row)
    unfollow_link.click

    # confirm that we don't find bob in the leaders row anymore
    leader_row = find_leader_row_in_people_table(@bob)
    expect(leader_row).to be_nil

    visit videos_path
    follow_leader_who_reviewed_movie(@star_wars, @bob)
    expect(page).to have_content "People I Follow"
    leader_row = find_leader_row_in_people_table(@bob)
    expect(leader_row).not_to be_nil
  end

  scenario "user alice follows user bob and cannot follow him again" do
    sign_in_user_via_ui(@alice.email, "pass")
    follow_leader_who_reviewed_movie(@star_wars, @bob)

    # should take us to people page
    expect(page).to have_content "People I Follow"

    # should list Bob Doe in a row in the listing
    leader_row = find_leader_row_in_people_table(@bob)
    expect(leader_row).not_to be_nil

    leader_link = find_leader_link_in_people_table(@bob)
    expect(leader_link).not_to be_nil
    
    leader_link.click
  
    expect(page).to have_content("#{@bob.fullname}'s video collections")
    expect(page).not_to have_selector("input[value='Follow']")
  end

  scenario "user alice cannot follow herself" do
    sign_in_user_via_ui(@alice.email, "pass")
    visit_leader_who_reviewed_movie(@jaws, @alice)
    expect(page).to have_content("#{@alice.fullname}'s video collections")
    expect(page).not_to have_selector("input[value='Follow']")
  end

  scenario "user alice follows bob then charlie, and both are listed in people I follow page" do
    sign_in_user_via_ui(@alice.email, "pass")
    follow_leader_who_reviewed_movie(@star_wars, @bob)

    # should take us to people page
    expect(page).to have_content "People I Follow"

    # should list Bob Doe in a row in the listing
    leader_row = find_leader_row_in_people_table(@bob)
    expect(leader_row).not_to be_nil

    leader_row = find_leader_row_in_people_table(@charlie)
    expect(leader_row).to be_nil

    visit videos_path
    follow_leader_who_reviewed_movie(@usual_suspects, @charlie)    
    # should list Bob Doe in a row in the listing
    leader_row = find_leader_row_in_people_table(@bob)
    expect(leader_row).not_to be_nil

    leader_row = find_leader_row_in_people_table(@charlie)
    expect(leader_row).not_to be_nil
  end
end
