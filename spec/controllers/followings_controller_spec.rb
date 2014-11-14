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

      it "sets @followings to the empty collection if there are no leader/follower relationships" do
        get :index
        expect(assigns(:followings)).to eq([])
      end

      it "sets @followings to the empty collection if the current user does not follow anyone" do
        alice = Fabricate(:user, fullname: "Alice Doe")
        bob = Fabricate(:user, fullname: "Bob Doe")
        alice_follows_bob = Following.create(follower: alice, leader: bob)

        get :index
        expect(assigns(:followings)).to eq([])
      end

      it "sets @followings to the set of following relationship entries where the current user is the follower" do
        alice = Fabricate(:user, fullname: "Alice Doe")
        bob = Fabricate(:user, fullname: "Bob Doe")
        charlie = Fabricate(:user, fullname: "Charlie Doe")

        user_follows_alice = Following.create(follower: @user, leader: alice)
        alice_follows_bob = Following.create(follower: alice, leader: bob)
        user_follows_charlie = Following.create(follower: @user, leader: charlie)
        alice_follows_charlie = Following.create(follower: alice, leader: charlie)
        bob_follows_user = Following.create(follower: bob, leader: @user)
        bob_follows_alice = Following.create(follower: bob, leader: alice)

        get :index
        expect(assigns(:followings)).to eq([user_follows_alice, user_follows_charlie])
      end

      it "renders the index template" do
        get :index
        expect(response).to render_template :index
      end
    end
  end # GET index

  describe "DELETE destroy" do
    context "no logged in user" do
      before do
        leader = Fabricate(:user)
        follower = Fabricate(:user)
        @following = Following.create(leader: leader, follower: follower)
      end

      it_behaves_like("require_sign_in") { let(:action) { delete :destroy, id: @following.id } }

      it "does not destroy the following" do
        delete :destroy, id: @following.id        
        expect(Following.all).to eq([@following])
      end
    end

    context "logged in user" do
      before do
        @user = Fabricate(:user)
        set_current_user(@user)
      end

      context "invalid id when no followings" do
        it_behaves_like("danger_flash_and_people_path_redirect") { let(:action) { delete :destroy, id: 1 } }
      end


      context "invalid ID when some followings exist" do
        before do
          leader = Fabricate(:user)
          Following.create(leader: leader, follower: @user)
        end

        it_behaves_like("danger_flash_and_people_path_redirect") { let(:action) { delete :destroy, id: 2 } }
      end

      context "valid ID when followings exist" do

        context "id identifies a follower who is not the current user" do
          before do
            leader = Fabricate(:user)
            alice = Fabricate(:user)
            @following = Following.create(leader: leader, follower: alice)
          end

          it "does not destroy the relationship for which the current user is not the follower" do
            delete :destroy, id: @following.id
            expect(Following.all).to eq([@following])
          end

          it_behaves_like("danger_flash_and_people_path_redirect") { let(:action) { delete :destroy, id: @following.id } } 
        end

        context "id identifies a follower who is the current user" do
          before do
            leader = Fabricate(:user)
            alice = Fabricate(:user)
            @alice_following_leader = Following.create(leader: leader, follower: alice)
            @user_following_leader = Following.create(leader: leader, follower: @user)
          end

          it "destroys the following relationship identified in the URL parameter" do
            expect(Following.all).to eq([@alice_following_leader, @user_following_leader])
            delete :destroy, id: @user_following_leader.id
            expect(Following.all).to eq([@alice_following_leader])
          end


          it "redirects to the people page" do
            delete :destroy, id: @user_following_leader.id
            expect(response).to redirect_to people_path
          end
        end
      end # valid ID
    end # user logged in
  end # DELETE destroy

  describe "POST create" do
    context "no logged in user" do
      before do
        @leader = Fabricate(:user)
        follower = Fabricate(:user)
        @following = Following.create(leader: @leader, follower: follower)
      end

      it_behaves_like("require_sign_in") { let(:action) { post :create, user_id: @leader.id } }

      it "does not create the following" do
        post :create, user_id: @leader.id        
        expect(Following.all).to eq([@following])
      end
    end # no logged in user

    context "logged in user" do
      before do
        @leader = Fabricate(:user)
        follower = Fabricate(:user)
        @following = Following.create(leader: @leader, follower: follower)

        @alice = Fabricate(:user)
        set_current_user(@alice)
      end

      context "specified leader ID in URL parameters is invalid" do
        it_behaves_like("danger_flash_and_people_path_redirect") { let(:action) { post :create, user_id: User.count + 1 } } 

        it "does not create a new following" do
          post :create, user_id: User.count+1

          expect(Following.all).to eq([@following])
        end
      end

      context "specified leader ID in URL parameters is valid" do
        before { post :create, user_id: @leader.id }

        it "creates a relationship for the current logged in user to follow the leader specified in user_id" do
          expect(Following.count).to eq(2)
          expect(Following.find_by(leader_id: @leader, follower_id: @alice)).not_to be_nil
        end

        it "redirects to the people page" do
          expect(response).to redirect_to people_path
        end
      end

      context "the current user already follows the leader specified by the user ID in the parameters" do
        it "does not create a new relationship" do
          @following = Following.create(leader: @leader, follower: @alice)        
          expect(Following.count).to eq(2)
          post :create, user_id: @leader.id
          expect(Following.count).to eq(2)
        end
      end

      context "specified leader ID is the current user" do
        before { post :create, user_id: @alice.id }

        it "does not create a relationship" do
          expect(Following.count).to eq(1)
          expect(Following.find_by(leader_id: @alice, follower_id: @alice)).to be_nil
        end

        it_behaves_like("danger_flash_and_people_path_redirect") { let(:action) { } }
      end
    end # logged in user
  end # POST create
end

