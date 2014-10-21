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
  end # GET index

  describe "POST create" do
    before do
      Fabricate(:user)
      Fabricate(:video)
    end

    context "no logged in user" do
      context "user_id is supplied" do
        it "redirects to the sign in page" do
          post :create, user_id: 1, video_id: 1
          expect(response).to redirect_to sign_in_path
        end
      end

      context "user_id is not supplied" do
        it "redirects to the sign in page" do
          post :create, user_id: 1, video_id: 1
          expect(response).to redirect_to sign_in_path
        end
      end

    end # no logged in user

    context "logged in user" do
      let(:user) { Fabricate(:user) }
      before do
        session[:userid] = user.id
      end

      context "user_id explicitly supplied" do
        context "user_id in params does not match current logged in user" do
          let(:user2) { Fabricate(:user) }
          before { post :create, video_queue_entry: { user_id: user2.id, position: 1, video_id: 1 } }
          
          it("redirects to home path") { expect(response).to redirect_to home_path }
          it("sets a flash message") { expect(flash[:danger]).not_to be_nil }
        end

        it "sets @user to the user specified by the ID" do
          user2 = Fabricate(:user)
          post :create, video_queue_entry: { user_id: user2.id, position: 1, video_id: 1 }
          expect(assigns(:user)).to eq(user2)
        end

      end

      context "user_id ommitted" do
        it "sets @user to the current user" do
          post :create, video_queue_entry: { position: 1, video_id: 1 }
          expect(assigns(:user)).to eq(user)
        end
      end

      context "valid inputs and user and video" do
        before { post :create, video_queue_entry: { position: 1, video_id: 1 } }

        it("adds a video entry to the users's queue") { expect(user.video_queue_entries.size).to eq(1) }
        it("adds the video specified by video_id as a queued video in the users's queue") { 
          expect(user.queued_videos).to include(Video.first) }
        it("redirects to the my_queue path") { expect(response).to redirect_to my_queue_path }
        it("sets a success flash message") { expect(flash[:success]).not_to be_nil }
      end

      context "omitted video field" do
        before { post :create, video_queue_entry: { position: 1 } }

        it("sets a flash message if video_id is omitted") { expect(flash[:danger]).not_to be_nil }
        it("redirects to home_path if video_id is omitted") { expect(response).to redirect_to home_path }
      end

      context "video id does not identify a valid video" do
        before { post :create, video_queue_entry: { position: 1, video_id: 2 } }
        
        it("sets a danger flash message") { expect(flash[:danger]).not_to be_nil }
        it("redirects to home_path") { expect(response).to redirect_to home_path }
      end

      context "omitted position field" do
        before do
          video2 = Fabricate(:video)
          video3 = Fabricate(:video)
          Fabricate(:video_queue_entry, user: user, video: video2, position: 1)
          Fabricate(:video_queue_entry, user: user, video: video3, position: 2)

          post :create, video_queue_entry: { video_id: 1 }
        end

        it("adds the video as the last video in the queue") do
          expect(user.queued_videos.size).to eq(3)
          expect(user.queued_videos).to include(Video.first)
        end

        it("redirects to my_queue") { expect(response).to redirect_to my_queue_path }
        it("sets a success flash message") { expect(flash[:success]).not_to be_nil }
      end

      context "video already in user's queue" do
        before do
          Fabricate(:video_queue_entry, user: user, video: Video.first, position: 1)
          post :create, video_queue_entry: { position: 2, video_id: 1 }
        end

        it("sets a danger flash message") { expect(flash[:danger]).not_to be_nil }
        it("redirects to my queue path") { expect(response).to redirect_to my_queue_path }
      end

      ### is the following a useful test?
      # context "position value already is taken in the queue" do
      #   it "appends the video to the end of the user queue"
      # end
      

    end # logged in user

  end # POST create

end

