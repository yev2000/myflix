require 'rails_helper'

require Rails.root.to_s + "/lib/seed_support"

describe VideoqueueController do

  describe "GET index" do
    context "no logged in user" do
      context "user_id is supplied" do
        it "redirects to the sign in page" do
          get :index, user_id: 1
          expect(response).to redirect_to sign_in_path
        end
      end
  
      context "user_id is not supplied" do
        it "redirects to the sign in page" do
          get :index
          expect(response).to redirect_to sign_in_path
        end
      end
    end # no logged in user

    context "logged in user" do
      let(:user) { Fabricate(:user) }
      before { session[:userid] = user.id }

      context "user_id explicitly supplied" do
        context "user_id in params does not match current logged in user" do
          let(:user2) { Fabricate(:user) }
          before { get :index, user_id: user2.id }
          
          it("redirects to root") { expect(response).to redirect_to home_path }
          it("sets a flash message") { expect(flash[:danger]).not_to be_nil }
        end

        it "sets @user to the user specified by the ID" do
          user2 = Fabricate(:user)
          get :index, user_id: user2.id
          expect(assigns(:user)).to eq(user2)
        end

        context "no video queue entries for user" do
          before { get :index, user_id: user.id }

          it("sets @queue_entries to empty array") { expect(assigns(:queue_entries)).to eq([]) }
          it("renders index template") { expect(response).to render_template :index }
        end

        context "a video exists in the user's queue" do
          it "sets @queue_entries" do
            video = Fabricate(:video)
            vqe = Fabricate(:video_queue_entry, user: user, video: video)

            get :index, user_id: user.id
            expect(assigns(:queue_entries)).to eq([vqe])
          end

        end
      end # user ID explicitly supplied

      context "user_id is not supplied in params" do
        it("sets @user to the current user") do
          get :index
          expect(assigns(:user)).to eq(user)
        end

        context "no video queue entries for user" do
          before { get :index }

          it("sets @queue_entries to empty array") { expect(assigns(:queue_entries)).to eq([]) }
          it("renders index template") { expect(response).to render_template :index }
        end

        context "a video exists in the user's queue" do
          it "sets @queue_entries" do
            video = Fabricate(:video)
            vqe = Fabricate(:video_queue_entry, user: user, video: video)

            get :index
            expect(assigns(:queue_entries)).to eq([vqe])
          end
        end

      end # user id not supplied
    end
  end
end

