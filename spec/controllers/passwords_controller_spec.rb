require 'rails_helper'

require Rails.root.to_s + "/lib/seed_support"

describe PasswordsController do 
  describe "GET forgot_password" do
    it "renders the forgot_password page" do
      get :forgot_password
      expect(response).to render_template :forgot_password
    end
  end # GET forgot_password

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

      it "sets a unique token each time" do
        post :email_reset_link, email: @forgetful.email
        @forgetful.reload
        token1 = @forgetful.password_reset_token
        
        post :email_reset_link, email: @forgetful.email
        @forgetful.reload
        token2 = @forgetful.password_reset_token
        
        post :email_reset_link, email: @forgetful.email
        @forgetful.reload
        token3 = @forgetful.password_reset_token

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

      it "redirects to the invalid password reset token page" do
        expect(response).to redirect_to invalid_password_reset_token_path
      end

      it "does not reset any user's password" do
        @alice.reload
        expect(@alice.authenticate("ABCD")).to eq(@alice)

        @bob.reload
        expect(@bob.authenticate("DEFG")).to eq(@bob)
      end

    end
  end # GET reset_password

  describe "POST update_password" do
    before do
      @alice = Fabricate(:user, password: "ABCD", password_reset_token: SecureRandom.urlsafe_base64)
      @bob = Fabricate(:user, password: "EFGH", password_reset_token: SecureRandom.urlsafe_base64)
    end

    context "successful password change" do
      before do
        @original_token = @alice.password_reset_token
        post :update_password, token: @alice.password_reset_token, password: "QQQQaa", password_confirm: "QQQQaa"
        @alice.reload
        @bob.reload
      end
      
      it "updates user password if password and password confirm match" do
        expect(@alice.authenticate("QQQQaa")).to eq(@alice)
      end

      it "sets the password_reset_token for the user to nil" do
        expect(@alice.password_reset_token).to be_nil
      end

      it "redirects to the sign_in page" do
        expect(response).to redirect_to sign_in_path
      end

      it("sets a success flash") { expect(flash[:success]).not_to be_nil }

      context "attempt to reuse token that was already used to reset a password" do
        before do
          post :update_password, token: @original_token, password: "newone", password_confirm: "newone"
          @alice.reload
        end

        it "redirects to the invalid password reset token page" do
          expect(response).to redirect_to invalid_password_reset_token_path
        end

        it "does not change the user's password" do
          expect(@alice.authenticate("QQQQaa")).to eq(@alice)
        end
      end

    end # successful password change

    context "password confirmation did not match" do
      before do
        post :update_password, token: @alice.password_reset_token, password: "QQQQaa", password_confirm: "QQQQbb"
        @alice.reload
      end
      
      it "renders the reset_password template" do
        expect(response).to render_template :reset_password
      end

      it "does not change the user's password" do
        expect(@alice.authenticate("ABCD")).to eq(@alice)
      end

      it "does not set the user's password_reset_token to nil" do
        expect(@alice.password_reset_token).not_to be_nil
      end

    end # not matching password confirmation

    context "supplied password_reset_token does not match any user's token" do
      before do
        post :update_password, token: SecureRandom.urlsafe_base64, password: "QQQQaa", password_confirm: "QQQQbb"
        @alice.reload
        @bob.reload
      end

      it "redirects to the invalid password reset token page" do
        expect(response).to redirect_to invalid_password_reset_token_path
      end

      it "does not change the any user's password" do
        expect(@alice.authenticate("ABCD")).to eq(@alice)
        expect(@bob.authenticate("EFGH")).to eq(@bob)
      end

      it "does not set any user's password_reset_token to nil" do
        expect(@alice.password_reset_token).not_to be_nil
        expect(@bob.password_reset_token).not_to be_nil
      end
    end

  end # POST update_password

end
