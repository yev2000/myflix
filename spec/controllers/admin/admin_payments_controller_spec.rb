require 'rails_helper'

describe Admin::PaymentsController do 
  describe "GET index" do
    context "no logged in user" do
      it_behaves_like("require_sign_in") { let(:action) { get :index } }
    end

    context "not logged in admin" do
      it_behaves_like("require_admin") { let(:action) { get :index } }
    end

    context "admin logged in" do
      before do
        set_current_admin_user
        get :index
      end

      it "renders the index template" do
        expect(response).to render_template :index
      end

      it "sets @payments instance variable" do
        expect(assigns(:payments)).not_to be_nil
      end
    end 
  end # GET index
end

