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
          expect(Video.first.cover_url).to match("no_image.jpg")
        end

        it "flashes a success message" do
          expect(flash[:success]).not_to be_empty
        end

        it "redirects to the show_video path for the newly created video" do
          expect(response).to redirect_to video_path(Video.first)
        end

      end

      context "valid arguments with supplied file" do
        before do
          image = Rack::Test::UploadedFile.new(Rails.root + "spec/support/attachments/monk.jpg")
          post :create, video: {title: "a title", category_ids: [@comedies.id.to_s, @drama.id.to_s], description: "a description", cover: image }
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
          # "https://myflix-yev.s3.amazonaws.com/test/uploads/video/cover/<video ID>/<file name>"

          expect(Video.first.cover_url).to eq("https://myflix-yev.s3.amazonaws.com/test/uploads/video/cover/#{Video.first.id}/monk.jpg")
        end

        it "flashes a success message" do
          expect(flash[:success]).not_to be_empty
        end

        it "redirects to the show_video path for the newly created video" do
          expect(response).to redirect_to video_path(Video.first)
        end
      end

      context "missing title" do
        before { post :create, video: {category_ids: [@comedies.id.to_s, @drama.id.to_s], description: "a description" } }

        it "renders the new template" do
          expect(response).to render_template :new
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

        it "does not create a new video" do
          expect(Video.all.size).to eq(0)
        end
      end

    end
  end # POST create
end # Admin::VideosController

