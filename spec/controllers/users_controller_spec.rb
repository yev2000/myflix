require 'rails_helper'

require Rails.root.to_s + "/lib/seed_support"

describe UsersController do 
  describe "GET new" do
    it "shows new user template" do
      get :new
      expect(response).to render_template "new"
    end

    it "sets @user a fresh user" do
      get :new
      expect(assigns(:user)).to be_a(User)
      expect(assigns(:user).new_record?).to be true
    end
  end

  describe "GET show" do
    context "no logged in user" do
      it_behaves_like("require_sign_in") { let(:action) { get :show, id: 1 } }
    end

    context "logged in user" do
      before { set_current_user }

      context "valid user ID supplied" do
        before do
          @alice = Fabricate(:user)
          get :show, id: @alice.id
        end

        it("renders the show user template") { expect(response).to render_template "show" }
        
        it "sets @user to the user specified in the URL parameters" do
          expect(assigns(:user)).to eq(@alice)
        end

        it "sets @fresh_following if the user is not being followed by the current user" do
          expect(assigns(:fresh_following)).to be_a(Following)
          expect(assigns(:fresh_following).new_record?).to be true
        end
      end

      it "does not set @fresh_following if the user is already being followed by the current user" do
        leader = Fabricate(:user)
        Following.create(leader: leader, follower: spec_get_current_user)
        get :show, id: leader.id
        expect(assigns(:fresh_following)).to be_nil
      end

      it "does not set @fresh_following if the user is the current user" do
        get :show, id: spec_get_current_user.id
        expect(assigns(:fresh_following)).to be_nil
      end
      
      context "invalid user ID supplied" do
        before do
          alice = Fabricate(:user)
          get :show, id: User.last.id + 1
        end

        it("flashes a danger message") { expect_danger_flash }
        it("redirects to root path") { expect(response).to redirect_to root_path }
      end

    end # logged in user

  end # GET show

  describe "POST create" do
    context "valid user creation" do
      before do
        post :create, { user: {email: "joe@company.com", fullname: "joe smith", password: "pass", password_confirm: "pass"} }  
      end

      after { ActionMailer::Base.deliveries.clear }

      it "creates a new user if user does not already exist" do
        u = User.first
        expect(u.email).to eq("joe@company.com")
      end

      it "renders home template if user created" do
        expect(response).to redirect_to home_path
      end

      it "logs user in, if user created" do
        expect(session[:userid]).to eq(1)
      end

      it "sends an email" do
        expect(ActionMailer::Base.deliveries).not_to be_empty
      end

      it "sends an email to the email address of the created user" do
        message = ActionMailer::Base.deliveries.first
        expect(message.to).to eq([User.first.email])
      end

      it "has a welcome message in the email body" do
        message = ActionMailer::Base.deliveries.first
        if message.parts.size > 0
          message.parts.each do |part|
            expect(part.body).to include("Welcome to MyFlix!")
            expect(part.body).to include(User.first.fullname)
          end
        else
          expect(message.body).to include("Welcome to MyFlix!")
          expect(message.body).to include(User.first.fullname)
        end
      end
    end

    context "invalid user creation" do
      it "fails to create a new user if the password confirmation does not match password" do
        post :create, { user: {email: "joe@company.com", fullname: "joe smith", password: "pass", password_confirm: "foo"} }

        u = User.first
        expect(u).to eq(nil)
      end

      it "sets the @user instance variable to the email and username in the form if the password confirmation does not match password" do
        post :create, { user: {email: "joe@company.com", fullname: "joe smith", password: "pass", password_confirm: "foo"} }
        expect(assigns(:user).email).to eq("joe@company.com")
        expect(assigns(:user).fullname).to eq("joe smith")
      end

      it "fails to create a new user if the email already exists, and renders the new template again" do
        joe_user = Fabricate(:user, email: "joe@company.com")
        post :create, { user: {email: "joe@company.com", fullname: "maggie_smith", password: "pass", password_confirm: "pass"} }

        expect(User.all.size).to eq(1)
        expect(response).to render_template :new
      end

      it "does not send out a welcome email if user already exists" do
        joe_user = Fabricate(:user, email: "joe@company.com")

        # this should fail because this is a duplicate email"
        post :create, { user: {email: "joe@company.com", fullname: "Joe Doe", password: "pass", password_confirm: "pass"} }
        
        expect(ActionMailer::Base.deliveries).to be_empty
      end

    end
  end

  describe "GET edit" do
    context "no logged in user" do
      it "redirects to the sign_in screen" do
        u = Fabricate(:user)
        expect(User.find(1)).not_to be_nil
        get :edit, id: 1
        expect(response).to redirect_to sign_in_path
      end
    end

    context "user logged in" do
      before do
        u = Fabricate(:user)
        session[:userid] = 1
      end

      it "redirects to the front path if no user identified by the ID exists" do
        get :edit, id: "2"
        expect(response).to redirect_to root_path
      end

      it "sets the @user instance variable to the id specified by the id parameter" do
        get :edit, id: "1"
        expect(assigns(:user)).to eq(User.first)
      end

      it "renders the edit template" do
        get :edit, id: "1"
        expect(response).to render_template :edit
      end
    end
  end

  describe "POST update" do
    context "no logged in user" do
      it "redirects to the sign_in screen" do
        post :update, id: "1", user: {email: "a@b.c", fullname: "jane smith"}
        expect(response).to redirect_to sign_in_path
      end
    end
  
    context "logged in user" do
      before do
        u = Fabricate(:user, fullname: "jane smith")
        session[:userid] = 1
      end

      it "redirects to the front path if no user identified by the ID exists" do
        post :update, id: "2", user: {fullname: "joe smith"}
        expect(response).to redirect_to root_path
      end
      
      it "updates username if it was modified" do
        expect(User.first.fullname).to eq("jane smith")
        post :update, id: "1", user: {fullname: "joe smith"}
        expect(User.first.fullname).to eq("joe smith")
      end

      it "redirects to the show user page if successfully edited user" do
        post :update, id: "1", user: {fullname: "joe smith"}
        expect(response).to redirect_to user_path(User.find(1))
      end

      it "does not update password if password and password confirm don't match" do
        post :update, id: "1", user: {password: "aaaa", password_confirm: "bbbb" }
        expect(User.first.authenticate("aaaa")).to eq(false)
      end

      it "renders the edit screen if password and password confirm don't match" do
        post :update, id: "1", user: {password: "aaaa", password_confirm: "bbbb" }
        expect(response).to render_template :edit
      end

      it "renders the edit screen if user by email already exists" do
        user_1 = User.find(1)
        user_2 = Fabricate(:user)
        post :update, id: "2", user: {email: user_1.email}
        expect(User.find(2).email).not_to eq(user_1.email)
        expect(response).to render_template :edit
      end

      it "updates user password if password and password confirm match" do
        post :update, id: "1", user: {password: "QQQQaa", password_confirm: "QQQQaa" }
        u = User.first
        expect(u.authenticate("QQQQaa")).to eq(u)
      end

    end

  end # POST update
end
