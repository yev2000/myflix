require 'rails_helper'
require Rails.root.to_s + "/lib/seed_support"

describe Admin::VideosController do 
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
end # Admin::VideosController

