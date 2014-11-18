shared_examples "require_sign_in" do
  it "redirects to the sign in page" do
    clear_current_user
    action
    expect(response).to redirect_to sign_in_path
  end
end

shared_examples "require_valid_video" do
  it "sets @video to nil" do
    action
    assigns(:video).should be_nil
  end

  it "redirects to the /videos URL" do
    action
    expect(response).to redirect_to videos_path
  end
end

shared_examples "empty_search_results" do
  it "sets the search results to empty array when nil" do
    action
    assigns(:search_results).should eq([])
  end

  it "renders the search template when nil" do
    action
    expect(response).to render_template :search
  end
end

shared_examples "danger_flash_and_people_path_redirect" do
  it "flashes a danger message" do
    action
    expect_danger_flash
  end

  it "redirects to the people path" do
    action
    expect(response).to redirect_to people_path
  end
end

shared_examples "tokenable" do
  it "generates a random token" do
    expect(object.token).to be_present
  end
end