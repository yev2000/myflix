require 'rails_helper'

require Rails.root.to_s + "/lib/seed_support"

describe UsersController do 
  describe "GET new" do
    it "shows new user template" do
      get :new
      expect(response).to render_template "new"
    end

    it "sets the user instance variable to a fresh user" do
      get :new
      expect(assigns(:user)).to be_a(User)
    end
  end

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

  describe "POST email_reset_link" do   
    context "email identifies a user in the system" do
      before do
        3.times do
          Fabricate(:user)
        end

        @forgetful = Fabricate(:user, email: "forgetful@aaa.com")

        post :email_reset_link, email: @forgetful.email
      end

      after { ActionMailer::Base.deliveries.clear }

      it "sets @user instance variable to the user identified by the email parameter" do
        @forgetful.reload
        expect(assigns(:user)).to eq(@forgetful)
      end

      it "sets a one-time token for the user" do
        @forgetful.reload
        expect(@forgetful.password_reset_token).not_to be_nil
      end

      it "sends an email" do
        expect(ActionMailer::Base.deliveries).not_to be_empty
      end

      it "sends an email to the email address specified in the reset request" do
        message = ActionMailer::Base.deliveries.first
        expect(message.to).to eq([@forgetful.email])
      end

      it "the reset email has the reset token link in its body" do
        @forgetful.reload
        message = ActionMailer::Base.deliveries.first
        if message.parts.size > 0
          message.parts.each do |part|
            expect(part.body).to include(@forgetful.password_reset_token)
          end
        else
          expect(message.body).to include(@forgetful.password_reset_token)
        end
      end

      it "redirects to the confirm_password_reset page" do
        expect(response).to redirect_to confirm_password_reset_path
      end
    end

    context "email does not match any user's email" do
      before do
        3.times do
          Fabricate(:user)
        end  

        post :email_reset_link, email: "NONEXISTENT@nowhere.org"
      end

      it("flashes a danger message") { expect(flash[:danger]).not_to be_nil }

      it("redirects to the sign_in screen") { expect(response).to redirect_to sign_in_path }
      it "does not send out an email" do
        expect(ActionMailer::Base.deliveries).to be_empty
      end

      it "does not generate a reset token" do
        User.all.each do |user|
          expect(user.password_reset_token).to be_nil
        end
      end
    end
  end # POST email_reset_link

  describe "GET confirm_password_reset" do
    it "renders the confirm_password_reset page" do
      get :confirm_password_reset

      expect(response).to render_template :confirm_password_reset
    end
  end # GET confirm_password_reset

  describe "GET reset_password" do
    context "valid token" do
      before do
        @alice = Fabricate(:user, password: "ABCD")
        @bob = Fabricate(:user, password: "DEFG", password_reset_token: SecureRandom.urlsafe_base64)

        token = SecureRandom.urlsafe_base64
        @charlie = Fabricate(:user, password: "GHIJ", password_reset_token: token)
        
        get :reset_password, token: token
      end

      it "sets @user to the user in the token URL parameter" do
        expect(assigns(:user)).to eq(@charlie)
      end

      it "renders to reset_password form" do
        expect(response).to render_template :reset_password
      end

    end

    context "invalid token" do
      before do
        @alice = Fabricate(:user, password: "ABCD")
        @bob = Fabricate(:user, password: "DEFG", password_reset_token: SecureRandom.urlsafe_base64)
        
        token = SecureRandom.urlsafe_base64

        get :reset_password, token: token
      end

      it("flashes a danger message") { expect(flash[:danger]).not_to be_nil }

      it "redirects to the root path" do
        expect(response).to redirect_to root_path
      end

      it "does not reset any user's password" do
        @alice.reload
        expect(@alice.authenticate("ABCD")).to eq(@alice)

        @bob.reload
        expect(@bob.authenticate("DEFG")).to eq(@bob)
      end

    end
  end # GET reset_password

end
