require 'rails_helper'

require Rails.root.to_s + "/lib/seed_support"

describe ForgotPasswordsController do 
  describe "GET new" do
    it "renders the 'new' page" do
      get :new
      expect(response).to render_template :new
    end
  end # GET new

  describe "POST create" do
    context "email identifies a user in the system" do
      before do
        3.times do
          Fabricate(:user)
        end

        @forgetful = Fabricate(:user, email: "forgetful@aaa.com")

        post :create, email: @forgetful.email
      end

      after { ActionMailer::Base.deliveries.clear }

      it "sets @user instance variable to the user identified by the email parameter" do
        @forgetful.reload
        expect(assigns(:user)).to eq(@forgetful)
      end

      it "sets a one-time token for the user" do
        @forgetful.reload
        expect(@forgetful.token).not_to be_nil
      end

      it "sets a unique token each time" do
        post :create, email: @forgetful.email
        @forgetful.reload
        token1 = @forgetful.token
        
        post :create, email: @forgetful.email
        @forgetful.reload
        token2 = @forgetful.token
        
        post :create, email: @forgetful.email
        @forgetful.reload
        token3 = @forgetful.token

        expect([token1, token2, token3].uniq.size).to eq(3)
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
            expect(part.body).to include(@forgetful.token)
          end
        else
          expect(message.body).to include(@forgetful.token)
        end
      end

      it "redirects to the confirm_password_reset page" do
        expect(response).to redirect_to confirm_password_reset_path
      end
    end

    context "email is blank" do
      before do
        3.times do
          Fabricate(:user)
        end  

        post :create, email: ""
      end

      it("flashes a danger message") { expect(flash[:danger]).not_to be_nil }

      it("redirects to the forgot password page") { expect(response).to redirect_to forgot_password_path }
    end

    context "email does not match any user's email" do
      before do
        ActionMailer::Base.deliveries.clear

        3.times do
          Fabricate(:user)
        end  

        post :create, email: "NONEXISTENT@nowhere.org"
      end

      after { ActionMailer::Base.deliveries.clear }

      it("flashes a danger message") { expect(flash[:danger]).not_to be_nil }

      it("redirects to the forgot password screen") { expect(response).to redirect_to forgot_password_path }

      it "does not send out an email" do
        expect(ActionMailer::Base.deliveries).to be_empty
      end

      it "does not generate a reset token" do
        User.all.each do |user|
          expect(user.token).to be_nil
        end
      end
    end
  end # POST create

  describe "GET confirm_password_reset" do
    it "renders the confirm_password_reset page" do
      get :confirm_password_reset

      expect(response).to render_template :confirm_password_reset
    end
  end # GET confirm_password_reset

  describe "GET reset_password" do
    context "valid token" do
      before do
        @alice = Fabricate(:user, password: "old_alice_password")
        @bob = Fabricate(:user, password: "old_bob_password", token: SecureRandom.urlsafe_base64)

        token = SecureRandom.urlsafe_base64
        @charlie = Fabricate(:user, password: "old_charlie_password", token: token)

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
        @alice = Fabricate(:user, password: "old_alice_password")
        @bob = Fabricate(:user, password: "old_bob_password", token: SecureRandom.urlsafe_base64)
        
        token = SecureRandom.urlsafe_base64

        get :reset_password, token: token
      end

      it "redirects to the invalid password reset token page" do
        expect(response).to redirect_to invalid_password_reset_token_path
      end

      it "does not reset any user's password" do
        @alice.reload
        expect(@alice.authenticate("old_alice_password")).to eq(@alice)

        @bob.reload
        expect(@bob.authenticate("old_bob_password")).to eq(@bob)
      end

    end
  end # GET reset_password

  describe "POST update_password" do
    before do
      @alice = Fabricate(:user, password: "old_alice_password", token: SecureRandom.urlsafe_base64)
      @bob = Fabricate(:user, password: "old_bob_password", token: SecureRandom.urlsafe_base64)
    end

    context "successful password change" do
      before do
        @original_token = @alice.token
        post :update_password, token: @alice.token, password: "first_new_password", password_confirm: "first_new_password"
        @alice.reload
        @bob.reload
      end
      
      it "updates user password if password and password confirm match" do
        expect(@alice.authenticate("first_new_password")).to eq(@alice)
      end

      it "sets the token for the user to nil" do
        expect(@alice.token).to be_nil
      end

      it "redirects to the sign_in page" do
        expect(response).to redirect_to sign_in_path
      end

      it("sets a success flash") { expect(flash[:success]).not_to be_nil }

      context "attempt to reuse token that was already used to reset a password" do
        before do
          post :update_password, token: @original_token, password: "second_new_password", password_confirm: "second_new_password"
          @alice.reload
        end

        it "redirects to the invalid password reset token page" do
          expect(response).to redirect_to invalid_password_reset_token_path
        end

        it "does not change the user's password" do
          expect(@alice.authenticate("first_new_password")).to eq(@alice)
        end
      end

    end # successful password change

    context "password confirmation did not match" do
      before do
        post :update_password, token: @alice.token, password: "new_password", password_confirm: "new_passwordXX"
        @alice.reload
      end
      
      it "renders the reset_password template" do
        expect(response).to render_template :reset_password
      end

      it "does not change the user's password" do
        expect(@alice.authenticate("old_alice_password")).to eq(@alice)
      end

      it "does not set the user's token to nil" do
        expect(@alice.token).not_to be_nil
      end

    end # not matching password confirmation

    context "supplied password_reset_token is invalid" do
      before do
        post :update_password, token: SecureRandom.urlsafe_base64, password: "new_password", password_confirm: "new_password"
        @alice.reload
        @bob.reload
      end

      it "redirects to the invalid password reset token page" do
        expect(response).to redirect_to invalid_password_reset_token_path
      end

      it "does not change the any user's password" do
        expect(@alice.authenticate("old_alice_password")).to eq(@alice)
        expect(@bob.authenticate("old_bob_password")).to eq(@bob)
      end

      it "does not set any user's token to nil" do
        expect(@alice.token).not_to be_nil
        expect(@bob.token).not_to be_nil
      end
    end

  end # POST update_password

end
