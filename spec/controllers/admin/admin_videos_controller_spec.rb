require 'rails_helper'
require Rails.root.to_s + "/lib/seed_support"
require 'carrierwave/test/matchers'

describe Admin::VideosController do 
  include CarrierWave::Test::Matchers

  describe "GET new" do
    context "no logged in user" do
      it_behaves_like("require_sign_in") { let(:action) { get :new } }
    end

    context "not logged in admin" do
      it_behaves_like("require_admin") { let(:action) { get :new } }
    end

    context "admin logged in" do
      before do
        set_current_admin_user
        get :new
      end

      it "renders the new template" do
        expect(response).to render_template :new
      end

      it "sets @video to a new video" do
        expect(assigns(:video)).to be_new_record
        expect(assigns(:video)).to be_a(Video)
      end
    end 
  end # GET new

  describe "POST create" do
    before do
      @comedies = Fabricate(:category)
      @action = Fabricate(:category)
      @drama = Fabricate(:category)
    end

    context "no logged in user" do
      it_behaves_like("require_sign_in") { let(:action) { post :create, video: {title: "a title", category_ids: [@comedies.id.to_s, @drama.id.to_s], description: "a description" } } }
    end

    context "not logged in admin" do
      it_behaves_like("require_admin") { let(:action) { post :create, video: {title: "a title", category_ids: [@comedies.id.to_s, @drama.id.to_s], description: "a description" } } }
    end

    context "admin logged in" do
      before do
        set_current_admin_user
      end

      context "valid arguments without file specification" do
        before do
          post :create, video: {title: "a title", category_ids: [@comedies.id.to_s, @drama.id.to_s], description: "a description" }
        end
      
        it "creates a video associated with the specified categories" do
          expect(Video.all.size).to eq(1)
          expect(Video.first.categories).to match_array([@comedies, @drama])
          expect(Video.first.title).to eq("a title")
        end

        it "assigns the no_image file to the video, if no cover art has been provided" do
          expect(Video.first.small_cover_url).to match("no_image.jpg")
          expect(Video.first.large_cover_url).to match("no_image.jpg")
        end

        it "flashes a success message" do
          expect(flash[:success]).not_to be_empty
        end

        it "redirects to the show_video path for the newly created video" do
          expect(response).to redirect_to video_path(Video.first)
        end
      end # valid args without supplied file

      context "valid arguments with supplied file" do
        before do
          image_large = Rack::Test::UploadedFile.new(Rails.root + "spec/support/attachments/monk_large.jpg")
          image_small = Rack::Test::UploadedFile.new(Rails.root + "spec/support/attachments/monk_small.jpg")
          post :create, video: {title: "a title", category_ids: [@comedies.id.to_s, @drama.id.to_s], description: "a description", large_cover: image_large, small_cover: image_small }
        end

        after do
          delete_s3_video_upload(Video.first)
        end

        it "creates a video associated with the specified categories" do
          expect(Video.all.size).to eq(1)
          expect(Video.first.categories).to match_array([@comedies, @drama])
          expect(Video.first.title).to eq("a title")
        end

        it "assigns an Amazon S3 file to the video" do
          # file name structure for successful upload is
          # "https://myflix-yev.s3.amazonaws.com/test/uploads/video/large_cover/<video ID>/<file name>"
          # "https://myflix-yev.s3.amazonaws.com/test/uploads/video/small_cover/<video ID>/<file name>"
          expect(Video.first.large_cover_url).to eq("https://myflix-yev.s3.amazonaws.com/test/uploads/video/large_cover/#{Video.first.id}/monk_large.jpg")
          expect(Video.first.small_cover_url).to eq("https://myflix-yev.s3.amazonaws.com/test/uploads/video/small_cover/#{Video.first.id}/monk_small.jpg")
        end

        it "flashes a success message" do
          expect(flash[:success]).not_to be_empty
        end

        it "redirects to the show_video path for the newly created video" do
          expect(response).to redirect_to video_path(Video.first)
        end
      end # valid args with supplied file

      context "missing title" do
        before { post :create, video: {category_ids: [@comedies.id.to_s, @drama.id.to_s], description: "a description" } }

        it "renders the new template" do
          expect(response).to render_template :new
        end
        
        it "sets @video instance variable" do
          expect(assigns(:video)).not_to be_nil
          expect(assigns(:video).description).to eq("a description")
        end

        it "does not create a new video" do
          expect(Video.all.size).to eq(0)
        end
      end

      context "missing description" do
        before { post :create, video: {category_ids: [@comedies.id.to_s, @drama.id.to_s], title: "a title" } }        
        it "renders the new template" do
          expect(response).to render_template :new
        end

        it "sets @video instance variable" do
          expect(assigns(:video)).not_to be_nil
          expect(assigns(:video).title).to eq("a title")
        end

        it "does not create a new video" do
          expect(Video.all.size).to eq(0)
        end
      end
    end # admin logged in
  end # POST create

  describe "GET edit" do
    before do
      Fabricate(:video)
    end

    context "no logged in user" do
      it_behaves_like("require_sign_in") { let(:action) { get :edit, id: Video.first.id } }
    end

    context "not logged in admin" do
      it_behaves_like("require_admin") { let(:action) { get :edit, id: Video.first.id } }
    end

    context "admin logged in" do
      context "valid video ID" do
        before do
          set_current_admin_user
          @batman = Fabricate(:video)
          superman = Fabricate(:video)
          get :edit, id: @batman.id
        end

        it "renders the edit template" do
          expect(response).to render_template :edit
        end

        it "sets @video to the video identified by the id" do
          expect(assigns(:video)).to eq(@batman)
        end
      end

      context "invalid video ID" do
        before do
          set_current_admin_user
          Fabricate(:video)
          get :edit, id: Video.last.id + 1
        end

        it "flashes an error message if id does not identify a valid video" do
          expect_danger_flash
        end

        it "redirects to the home path" do
          expect(response).to redirect_to home_path
        end
      end
    end # admin logged in
  end # GET edit
end # Admin::VideosController

