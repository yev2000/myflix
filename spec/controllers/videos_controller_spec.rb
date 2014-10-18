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
      it "redirects to the front page" do
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
        assigns(:video).should be_nil
      end

      it "redirects to the videos/index URL if there are no videos in the database" do
        get :show, {id: "1"}
        expect(response).to redirect_to videos_path
      end

      it "sets the @video instance variable to the record identified by the id parameter if there is a single video in the system" do
        video = Fabricate(:video)

        get :show, {id: "1"}
        assigns(:video).should eq(video)
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

      it "sets the @video instance variable to nil if the video identified by the id parameter does not exist" do
        video1 = Fabricate(:video)
        video2 = Fabricate(:video)
        
        get :show, {id: "3"}
        assigns(:video).should be_nil
      end

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