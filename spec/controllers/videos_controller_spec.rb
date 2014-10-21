require 'rails_helper'

require Rails.root.to_s + "/lib/seed_support"

describe VideosController do 
  describe "GET index" do
    context "no logged in user" do
      it "redirects to the front page" do
        get :index
        expect(response).to redirect_to sign_in_path
      end
    end
  end

  #####################################
  #
  # Show
  #
  #####################################

  describe "GET show" do
    context "no logged in user" do
      it "redirects to the sign in page" do
        get :show, {id: "1"}
        expect(response).to redirect_to sign_in_path
      end
    end

    context "user is logged in" do
      before do
        u = Fabricate(:user)
        session[:userid] = 1
      end

      it "sets the @video instance variable to nil if there are no videos in the database" do
        get :show, {id: "1"}
        expect(assigns(:video)).to be_nil
      end

      it "redirects to the videos/index URL if there are no videos in the database" do
        get :show, {id: "1"}
        expect(response).to redirect_to videos_path
      end

      it "sets the @video instance variable to the record identified by the id parameter if there is a single video in the system" do
        video = Fabricate(:video)

        get :show, {id: "1"}
        expect(assigns(:video)).to eq(video)
      end

      it "sets the @video instance variable to the record identified by the id parameter if there is more than one video in the system" do
        video1 = Fabricate(:video)
        video2 = Fabricate(:video)
        video3 = Fabricate(:video)

        get :show, {id: "2"}
        assigns(:video).should eq(video2)
      end

      it "renders the show template if the video identified by id exists" do
        video1 = Fabricate(:video)
        video2 = Fabricate(:video)
        video3 = Fabricate(:video)

        get :show, {id: "2"}
        expect(response).to render_template :show
      end

      it "redirects to the /videos URL if the videos identified by the ID does not exist in the database" do
        video1 = Fabricate(:video)
        video2 = Fabricate(:video)
        
        get :show, {id: "3"}
        expect(response).to redirect_to videos_path
      end

      it "sets @video to nil if the video identified by the id parameter does not exist" do
        video1 = Fabricate(:video)
        video2 = Fabricate(:video)
        
        get :show, {id: "3"}
        assigns(:video).should be_nil
      end

      it "sets @review to a new/blank review if the current user has not yet reviewed the shown video" do
        video = Fabricate(:video)
        get :show, {id: "1"}
        expect(assigns(:review)).not_to be_nil
      end

      it "sets @review to nil if the user has already reviewed the video being shown" do
        video = Fabricate(:video)
        review = Fabricate(:review, video: video, user: User.first)
        get :show, {id: "1"}
        expect(assigns(:review)).to be_nil
      end

      context "My Queue button enablement" do
        before do
          Fabricate(:video)
          video2 = Fabricate(:video)
          Fabricate(:video_queue_entry, video: video2, user: User.first)
        end
  
        it "sets @video_queue_entry with information on video to be added if the video identified ID is not in the user's queue" do
          get :show, id: "1"
          expect(assigns(:video_queue_entry).video_id).to eq(1)
          expect(assigns(:video_queue_entry).position).to eq(2)
        end

        it "does not set @video_queue_entry if the video identified ID is already listed in the user's queue" do
          get :show, id: "2"
          expect(assigns(:video_queue_entry)).to eq(nil)
        end
        
      end # context of my queue button

    end # context user is logged in
  end # GET show


  #####################################
  #
  # Review
  #
  #####################################
  describe "POST create_review" do

    context "no logged in user" do
      it "redirects to the sign_in page" do
        post :create_review, {id: 1, review: Fabricate.attributes_for(:review) }
        expect(response).to redirect_to sign_in_path
      end
    end
  
    context "logged in user" do
      let(:user) { Fabricate(:user) }
      before { session[:userid] = user.id }

      context "missing video" do
        before { post :create_review, {id: 1, review: Fabricate.attributes_for(:review) } }

        it ("flashes an error message if video ID does not refer to an extant video") { expect(flash[:danger]).not_to eq(nil) }
        it ("redirects to videos URL if video ID does not refer to an extant video") { expect(response).to redirect_to videos_path }
        it ("does not create a review") { expect(Review.all.size).to eq(0) }

      end

      context "video exists" do
        before { Fabricate(:video) }

        it "sets @video" do
          post :create_review, {id: Video.first.id, review: Fabricate.attributes_for(:review) }
          expect(assigns(:video)).to eq(Video.first)
        end

        context "missing fields" do

          it "sets review instance variable with an error message if title is missing" do
            post :create_review, {id: Video.first.id, review: { rating: 4, body: "test body" }}
            expect(assigns(:review).errors.messages).not_to be_nil
          end

          it "sets @review with an error message if body is missing" do
            post :create_review, {id: Video.first.id, review: { rating: 4, title: "test title" }}
            expect(assigns(:review).errors.messages).not_to be_nil
          end

          it "sets @review with an error message if rating is missing" do
            post :create_review, {id: Video.first.id, review: { body: "test body", title: "test title" }}
            expect(assigns(:review).errors.messages).not_to be_nil
          end

          it "redirects to video show page if title is missing" do
            post :create_review, {id: Video.first.id, review: { rating: 4, body: "test body" }}
            expect(response).to render_template :show
          end

          it "redirects to video show page if body is missing" do
            post :create_review, {id: Video.first.id, review: { rating: 4, title: "test title" }}
            expect(response).to render_template :show
          end

          it "redirects to video show page if rating is missing" do
            post :create_review, {id: Video.first.id, review: { body: "test body", title: "test title" }}
            expect(response).to render_template :show
          end
        end # context of missing fields

        context "video exists and required review fields filled in" do
          context "video already reviewed by logged in user" do
            before do
              prior_review = Fabricate(:review, video: Video.first, user: user)
              post :create_review, {id: Video.first.id, review: Fabricate.attributes_for(:review) }
            end

            # only one review in the system - the one that was the prior_review
            # so no new ones added
            it("does not create the review") { expect(Review.all.size).to eq(1) }

            it("sets @review with an error message") { expect(assigns(:review).errors.messages).not_to eq(nil) }
            it("re-renders show video page") { expect(response).to render_template :show }
          end

          context "video not yet reviewed by logged in user" do
            before { post :create_review, id: Video.first.id, review: Fabricate.attributes_for(:review) }

            it("flashes success message for a valid review") { expect(flash[:success]).not_to be_nil }
            it("creates the review") { expect(Review.all.size).to eq(1) }
            it("associates the review with the reviewed video") { expect(Video.first.reviews.size).to eq(1) }
            it("associates the review with the current logged in user") { expect(Review.first.user).to eq(user) }
            it("redirects to show video page") { expect(response).to redirect_to video_path(Video.first) }
          end

        end # video exists and required fields all filled in
      end # video exists context
    end
  end


  #####################################
  #
  # Search
  #
  #####################################

  describe "GET search" do
    context "no logged in user" do
      it "redirects to the front page" do
        get :search
        expect(response).to redirect_to sign_in_path
      end
    end

    context "user is logged in" do
      before do
        u = Fabricate(:user)
        session[:userid] = 1
      end
  
      context "title_string parameter is nil or empty" do
        
        it "sets the search results to empty array when nil" do
          get :search
          assigns(:search_results).should eq([])
        end


        it "renders the search template when nil" do
          get :search
          expect(response).to render_template :search
        end

        it "sets the search results to empty array when empty string" do
          get :search, { title_string: "" }
          assigns(:search_results).should eq([])
        end

        it "renders the search template when empty string" do
          get :search, { title_string: "" }
          expect(response).to render_template :search
        end
      end

      context "title_string parameter is specified" do
        context "no videos in the database" do
          it "sets the search results to empty array" do
            get :search, { title_string: "goonies" }
            assigns(:search_results).should eq([])
          end

          it "renders the search template" do
            get :search, { title_string: "goonies" }
            expect(response).to render_template :search
          end
        end

        context "at least 1 video in the database" do
          let(:titanic) { Fabricate(:video, title: "Titanic") }

          it "sets the search_results instance variable to empty array if title_string does not match" do
            get :search, { title_string: "goonies" }
            assigns(:search_results).should eq([])
          end

          it "renders the search template if title_string does not match" do
            get :search, { title_string: "goonies" }
            expect(response).to render_template :search           
          end

          it "sets the search_results instance variable to an array containing the matching video if title_string does match" do
            get :search, { title_string: "ani" }
            assigns(:search_results).should eq([titanic])
          end

          it "renders the search template if title_string does match" do
            get :search, { title_string: "ani" }
            expect(response).to render_template :search           
          end
        end
      end
    end
  end
end