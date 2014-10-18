require 'rails_helper'

require Rails.root.to_s + "/lib/seed_support"

describe SessionsController do 
  describe "GET new" do
    it "redirects to the home screen for already logged in user" do
      u = Fabricate(:user)
      session[:userid] = 1
      
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
  end

  describe "POST create" do
    before do
      u = Fabricate(:user, { email: "foo@company.com", password: "password" })
    end

    it "renders new session template if user email was not found" do
      post :create, email: "bar@company.com", password: "password"
      expect(response).to render_template :new
    end

    it "sets login_email instance variable to user email entered if user not found" do
      post :create, email: "bar@company.com", password: "password"
      expect(assigns(:login_email)).to eq("bar@company.com")
    end

    it "renders new session template if user password was incorrect" do
      post :create, email: "foo@company.com", password: "pass"
      expect(response).to render_template :new
    end

    it "sets login_email instance variable to user email entered if user password was incorrect" do
      post :create, email: "foo@company.com", password: "pass"
      expect(assigns(:login_email)).to eq("foo@company.com")
    end

    it "sets session ID if user authenticated" do
      post :create, email: "foo@company.com", password: "password"
      expect(session[:userid]).to eq(1)
    end

    it "redirects to home_path if user authenticated" do
      post :create, email: "foo@company.com", password: "password"
      expect(response).to redirect_to home_path
    end

    it "redirects to categories path if prior to posting to session/create, the prior URL was the categories path" do
      session[:prior_url] = categories_path
      post :create, email: "foo@company.com", password: "password"
      expect(response).to redirect_to categories_path
    end

  end

  describe "GET destroy" do
    context "no logged in user" do
      it "clears out session information" do
        get :destroy
        expect(session[:userid]).to eq(nil)
      end

      it "redirects to application root path" do
        get :destroy
        expect(response).to redirect_to root_path
      end
    end

    context "logged in user" do
      before do
        u = Fabricate(:user)
        session[:userid] = 1
      end

      it "clears out session information" do
        get :destroy
        expect(session[:userid]).to eq(nil)
      end

      it "redirects to application root path" do
        get :destroy
        expect(response).to redirect_to root_path
      end
    end

  end
end
