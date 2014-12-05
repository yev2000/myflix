require 'rails_helper'

require Rails.root.to_s + "/lib/seed_support"

describe VideosController do 
  describe "GET index" do
    context "no logged in user" do
      it_behaves_like("require_sign_in") { let(:action) { get :index } }
    end
  end

  describe "GET watch" do
    before do
      Fabricate(:video)
    end

    context "no logged in user" do
      it_behaves_like("require_sign_in") { let(:action) { get :watch, id: Video.first.id } }
    end

    context "user is logged in" do
      before { set_current_user }

      it "sets @video to the specified video" do
        get :watch, id: Video.first.id
        expect(assigns(:video)).to eq(Video.first)
      end

      it "sets redirects to the videos path if the ID does not identify a valid video" do
        get :watch, id: Video.first.id + 1
        expect(response).to redirect_to videos_path
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
      it_behaves_like("require_sign_in") { let(:action) { get :show, {id: "1"} } }
    end

    context "user is logged in" do
      before { set_current_user }

      context "no videos in database" do
        it_behaves_like("require_valid_video") { let(:action) { get :show, {id: "1"} } }
      end

      it "sets the @video instance variable to the record identified by the id parameter if there is a single video in the system" do
        video = Fabricate(:video)

        get :show, {id: "1"}
        expect(assigns(:video)).to eq(video)
      end

      it "sets the @video instance variable to be decorated" do
        video = Fabricate(:video)

        get :show, {id: "1"}
        expect(assigns(:video)).to be_decorated
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

      context "parameter ID does not match existing video in the database" do
        it_behaves_like("require_valid_video") do
          let(:action) do
            video1 = Fabricate(:video)
            video2 = Fabricate(:video)
            get :show, {id: "3"}
          end
        end
      end

      it "sets @review to a new/blank review if the current user has not yet reviewed the shown video" do
        video = Fabricate(:video)
        get :show, {id: "1"}
        expect(assigns(:review)).not_to be_nil
      end

      it "sets @review to nil if the user has already reviewed the video being shown" do
        review = Fabricate(:review, video: Fabricate(:video), user: User.first)
        get :show, {id: "1"}
        expect(assigns(:review)).to be_nil
      end

      context "My Queue button enablement" do
        before do
          Fabricate(:video)
          Fabricate(:video_queue_entry, video: Fabricate(:video), user: User.first)
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
  # Search
  #
  #####################################

  describe "GET search" do
    context "no logged in user" do
      it_behaves_like("require_sign_in") { let(:action) { get :search } }
    end

    context "user is logged in" do
      before { set_current_user }
  
      context "title_string parameter is nil" do
        it_behaves_like("empty_search_results") { let(:action) { get :search } }
      end

      context "title_string parameter is empty" do
        it_behaves_like("empty_search_results") { let(:action) { get :search, { title_string: "" } } }
      end

      context "title_string parameter is specified" do
        context "no videos in the database" do
          it_behaves_like("empty_search_results") { let(:action) { get :search, { title_string: "goonies" } } }
        end

        context "at least 1 video in the database" do
          let(:titanic) { Fabricate(:video, title: "Titanic") }

          it_behaves_like("empty_search_results") { let(:action) { get :search, { title_string: "goonies" } } }

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
    end # user is logged in
  end # GET search
end # VideosController
