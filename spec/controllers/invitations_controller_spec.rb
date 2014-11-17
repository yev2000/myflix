require 'rails_helper'

require Rails.root.to_s + "/lib/seed_support"

describe InvitationsController do 
  describe "GET new" do

    context "no logged in user" do
      it_behaves_like("require_sign_in") { let(:action) { get :new } }
    end

    context "logged in user" do
      before { set_current_user }

      it "shows the new invitation template" do
        get :new
        expect(response).to render_template :new
      end

      it "sets @invitation to a new Invitation" do
        get :new
        expect(assigns(:invitation).new_record?).to be true
        expect(assigns(:invitation)).to be_instance_of(Invitation)
      end
    end

  end # GET new

  describe "POST create" do
    context "no logged in user" do
      it_behaves_like("require_sign_in") { let(:action) { post :create, invitation: { fullname: "Batman", email: "bwayne@gotham.gov", message: "Hey, Join MyFlix, batman!", user_id: 1 } } }
    end

    context "logged in user" do
      before do
        ActionMailer::Base.deliveries.clear
        set_current_user
      end
      
      after { ActionMailer::Base.deliveries.clear }


      context "valid inputs for invitation creation" do
        before do
          get :create, invitation: { fullname: "Batman", email: "bwayne@gotham.gov", message: "Hey, Join MyFlix, batman!", user_id: User.first.id }
        end

        it "creates a new invitation record with the submitted invitee name and email" do
          expect(Invitation.count).to eq(1)
          expect(Invitation.first.email).to eq("bwayne@gotham.gov")
          expect(Invitation.first.fullname).to eq("Batman")
        end

        it "sets a unique token in the invitation" do
          expect(Invitation.first.token).not_to be_nil
        end

        it "sets the user associated with the invitation to the current user" do
          expect(Invitation.first.user_id).to eq(spec_get_current_user.id)
        end

        it "sends an invitation email" do
          expect(ActionMailer::Base.deliveries).not_to be_empty
        end

        it "sends an invitation email to the invitation recipient" do
          message = ActionMailer::Base.deliveries.first
          expect(message.to).to eq([Invitation.first.email])
        end

        it "places the invitation's token in the invitation email" do
          message = ActionMailer::Base.deliveries.first
          expect(message.body).to include(Invitation.first.token)
        end

        it "flashes a success message" do
          expect(flash[:success]).not_to be_nil
        end

        it "redirects to the home path" do
          expect(response).to redirect_to home_path
        end
      end # valid inputs

      context "other invitations already exist for the invitee" do
        it "creates a new invitation" do
          user1 = Fabricate(:user)
          user2 = Fabricate(:user)
          user3 = Fabricate(:user)

          invitee_email = "alice@aaa.com"
          prior_invitation1 = Fabricate(:invitation, email: invitee_email, user: user1)
          to_still_preserve_invitation1 = Fabricate(:invitation, email: "charlie@ccc.com", user: user1)
          prior_invitation2 = Fabricate(:invitation, email: invitee_email, user: user2)
          to_still_preserve_invitation2 = Fabricate(:invitation, email: "charlene@ccc.com", user: user3)
          prior_invitation3 = Fabricate(:invitation, email: invitee_email, user: user1)
          to_still_preserve_invitation3 = Fabricate(:invitation, email: "cory@ccc.com", user: user2)

          get :create, invitation: { fullname: "Alice Doe", email: invitee_email, message: "Hey, Join MyFlix, Alice!", user_id: User.first.id }

          expect(Invitation.last.email).to eq(invitee_email)
          expect(Invitation.count).to eq(7)
        end
      end # other invitations exist 

      context "invalid inputs" do
        before do
          get :create, invitation: { fullname: "Batman", message: "Hey, Join MyFlix, batman!", user_id: User.first.id }
        end

        it "renders the new invitation template" do
          expect(response).to render_template :new
        end
 
        it "does not create an invitation" do
          expect(Invitation.count).to eq(0)
        end

        it "does not send out an email" do
          expect(ActionMailer::Base.deliveries).to be_empty
        end

      end # invalid inputs
    end # logged in user

  end # POST create

  describe "GET show" do
    context "valid token" do
      before do
        @invitation = Fabricate(:invitation)
        get :show, id: @invitation.token
      end

      it "sets @user to a fresh record" do
        expect(assigns(:user).new_record?).to be true
      end

      it "sets @invitation to the invitation in the input parameter" do
        expect(assigns(:invitation)).to eq(@invitation)
      end

      it "sets the username of @user to the username of the invitee of the invitation" do
        expect(assigns(:user).fullname).to eq(@invitation.fullname)
      end

      it "sets the email of @user to the email of the invitee of the invitation" do
        expect(assigns(:user).email).to eq(@invitation.email)
      end

      it "renders the new user page" do
        expect(response).to render_template "users/new"
      end
    end

    context "invalid token" do
      before do
        @invitation = Fabricate(:invitation)
        get :show, id: SecureRandom.urlsafe_base64
      end

      it "flashes a danger message" do
        expect_danger_flash
      end

      it "redirects to the sign_in page" do
        expect(response).to redirect_to sign_in_path
      end

    end
  end # GET show

end
