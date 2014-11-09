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

        user_f1 = Following.create(follower: @user, leader: alice)
        alice_f1 = Following.create(follower: alice, leader: bob)
        user_f2 = Following.create(follower: @user, leader: charlie)
        alice_f2 = Following.create(follower: alice, leader: charlie)
        bob_f1 = Following.create(follower: bob, leader: @user)
        bob_f2 = Following.create(follower: bob, leader: alice)

        get :index

        expect(assigns(:followings)).to eq([user_f1, user_f2])

      end

      it "renders the index template" do
        get :index
        
        expect(response).to render_template :index

      end


    end
  end # GET index


  describe "DELETE destroy" do

    context "no logged in user" do
      it_behaves_like("require_sign_in") { let(:action) { delete :destroy, id: 1 } }
    end

    context "logged in user" do
      before do
        @user = Fabricate(:user)
        set_current_user(@user)
      end

      context "invalid id when no followings" do
        it_behaves_like("invalid_followings_destroy") { let(:action) { delete :destroy, id: 1 } }
      end


      context "invalid ID when some followings exist" do
        before do
          leader = Fabricate(:user)
          Following.create(leader: leader, follower: @user)
        end

        it_behaves_like("invalid_followings_destroy") { let(:action) { delete :destroy, id: 2 } }
      end

      context "valid ID when followings exist" do

        context "id identifies a follower who is not the current user" do
          before do
            leader = Fabricate(:user)
            other_follower = Fabricate(:user)
            @following = Following.create(leader: leader, follower: other_follower)
          end

          it_behaves_like("invalid_followings_destroy") { let(:action) { delete :destroy, id: @following.id } } 
        end

        context "id identifies a follower who is the current user" do
          before do
            leader = Fabricate(:user)
            other_follower = Fabricate(:user)
            @following = Following.create(leader: leader, follower: other_follower)
            @my_following = Following.create(leader: leader, follower: @user)
          end

          it "destroys the following relationship" do
            expect(Following.all).to eq([@following, @my_following])
            
            delete :destroy, id: @my_following.id

            expect(Following.all).to eq([@following])
          end


          it "redirects to the people path" do
            delete :destroy, id: @my_following.id

            expect(response).to redirect_to people_path
          end

        end

      end # valid ID

    end # user logged in
  end # DELETE destroy

end
