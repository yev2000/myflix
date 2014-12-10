require 'rails_helper'

require Rails.root.to_s + "/lib/seed_support"

describe SessionsController do 
  describe "GET new" do
    it "redirects to the home screen for already logged in user" do
      u = Fabricate(:user)
      session[:userid] = u.id
      
      get :new
      expect(response).to redirect_to home_path
    end

    it "renders new session template if user not already logged in" do 
      get :new
      expect(response).to render_template :new
    end

    it "resets login_email instance variable to nil" do 
      get :new
      expect(assigns(:login_email)).to eq(nil)
    end
  end # GET new

  describe "POST create" do
    let(:the_user) { Fabricate(:user) }

    context "invalid email address" do
      before { post :create, email: (the_user.email + "XX"), password: the_user.password }

      it "renders new session template" do
        expect(response).to render_template :new
      end

      it "sets error message" do
        expect(flash[:danger]).not_to be_blank
      end

      it "sets @login_email to user email entered in form" do
        expect(assigns(:login_email)).to eq(the_user.email + "XX")
      end
    end

    context "invalid password" do
      before { post :create, email: the_user.email, password: (the_user.password + "XX") }

      it "renders new session template" do
        expect(response).to render_template :new
      end

      it "sets error message" do
        expect_danger_flash
      end

      it "sets @login_email to value entered in form" do
        expect(assigns(:login_email)).to eq(the_user.email)
      end

      it "leaves session key for user_id as nil" do
        expect(session[:userid]).to eq(nil)
      end

    end

    context "valid credentials" do
      context "account not locked" do
        before { post :create, email: the_user.email, password: the_user.password }

        it "sets session ID if user authenticated" do
          expect(session[:userid]).to eq(the_user.id)
        end

        it "redirects to home_path if user authenticated" do
          expect(response).to redirect_to home_path
        end
      end

      context "account locked" do
        before do
          the_user.account_locked = true
          the_user.save
          post :create, email: the_user.email, password: the_user.password
        end

        it "leaves session key for user_id as nil" do
          expect(session[:userid]).to eq(nil)
        end

        it "sets a danger flash" do
          expect_danger_flash
        end

        it "renders the new session template" do
          expect(response).to render_template :new
        end
      end
    end

    it "redirects to categories path if prior to posting to session/create, the prior URL was the categories path" do
      session[:prior_url] = categories_path
      post :create, email: the_user.email, password: the_user.password
      expect(response).to redirect_to categories_path
    end

  end # POST create

  describe "GET destroy" do

    context "no logged in user" do
      before { get :destroy }

      it "clears out session information" do
        expect(session[:userid]).to eq(nil)
      end

      it "redirects to application root path" do
        expect(response).to redirect_to root_path
      end
    end

    context "logged in user" do
      before do
        u = Fabricate(:user)
        session[:userid] = u.id
        get :destroy        
      end

      it "clears out session information" do
        expect(session[:userid]).to eq(nil)
      end

      it "redirects to application root path" do
        expect(response).to redirect_to root_path
      end

      it "sets the notice for logout" do
        expect(flash[:success]).not_to be_blank
      end

    end

  end # GET destroy
end
