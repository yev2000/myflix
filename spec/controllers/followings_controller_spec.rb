require 'rails_helper'

require Rails.root.to_s + "/lib/seed_support"

describe FollowingsController do 
  describe "GET index" do

    context "no logged in user" do
      it_behaves_like("require_sign_in") { let(:action) { get :index } }
    end

    context "logged in user" do
      before do
        @user = Fabricate(:user)
        set_current_user(@user)
      end


      it "sets @followings to the empty collection if there are no followings for the current user" do
        get :index

        expect(assigns(:followings)).to eq([])
      end

      it "sets @followings to the set of followings entries for the current user" do
        alice = Fabricate(:user, fullname: "Alice Doe")
        bob = Fabricate(:user, fullname: "Bob Doe")
        charlie = Fabricate(:user, fullname: "Charlie Doe")

        user_f1 = Following.create(user: @user, followed_user: alice)
        alice_f1 = Following.create(user: alice, followed_user: bob)
        user_f2 = Following.create(user: @user, followed_user: charlie)
        alice_f2 = Following.create(user: alice, followed_user: charlie)
        bob_f1 = Following.create(user: bob, followed_user: @user)
        bob_f2 = Following.create(user: bob, followed_user: alice)

        get :index

        expect(assigns(:followings)).to eq([user_f1, user_f2])

      end

      it "renders the index template" do
        get :index
        
        expect(response).to render_template :index

      end


    end
  end # GET index
end
