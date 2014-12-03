require 'rails_helper'

describe UserCreation do
  describe "#create_user" do
    context "valid credit card info" do
      before do
        charge = double('charge')
        charge.stub(:successful?).and_return(true)
        StripeWrapper::Charge.should_receive(:create).and_return(charge)

        flasher = double('flash')
        FlashCreation.stub(:new).and_return(flasher)

        @user = Fabricate.build(:user)
      end

      after { ActionMailer::Base.deliveries.clear }

      context "no invitation_token option supplied" do
        before do
          creation_service = UserCreation.new(@user, FlashCreation.new(nil), { stripeToken: "123" })
          @return_value = creation_service.create_user
        end

        it "returns true for successful user creation" do
          expect(@return_value).to eq(true)
        end

        it "creates a new user if user does not already exist" do
          expect(User.count).to eq(1)
          expect(User.first).to eq(@user)
        end

        it "sends an email" do
          expect(ActionMailer::Base.deliveries).not_to be_empty
        end

        it "sends an email to the email address of the created user" do
          message = ActionMailer::Base.deliveries.first
          expect(message.to).to eq([@user.email])
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
      end # no invitation token supplied

      context "invitation token supplied" do
        before do
          @inviter = Fabricate(:user)
          @invitation = Fabricate(:invitation, user: @inviter)
          @invitation_email = @invitation.email
          @invitation_token = @invitation.token

          @invited_user = Fabricate.build(:user, email: @invitation.email)
          creation_service = UserCreation.new(@invited_user, FlashCreation.new(nil), { stripeToken: "123", invitation_token: @invitation_token })
          creation_service.create_user

          @inviter.reload
        end
            
        it "creates a new user" do
          invited_user = User.find_by_email(@invitation_email)
          expect(invited_user).not_to be_nil
          expect(User.count).to eq(2)
        end 

        it "adds a follow relationship between the inviter and invitee user" do
          invited_user = User.find_by_email(@invitation_email)
          expect(invited_user.followers).to eq([@inviter])
        end

        it "adds a follow relationship between the invitee and inviter" do
          invited_user = User.find_by_email(@invitation_email)
          expect(@inviter.followers).to eq([invited_user])
        end

        it "destroys the invitation identified by the invitation token parameter" do
          expect(Invitation.find_by_token(@invitation_token)).to be_nil
          expect(Invitation.count).to eq(0)
        end
      end # registration due to invitation

      context "invitation token supplied where other invitations already exist for the invitee" do
        before do
          user1 = Fabricate(:user)
          user2 = Fabricate(:user)
          user3 = Fabricate(:user)

          @invitee_email = "alice@aaa.com"
          @prior_invitation1 = Fabricate(:invitation, email: @invitee_email, user: user1)
          @to_still_preserve_invitation1 = Fabricate(:invitation, email: "charlie@ccc.com", user: user1)
          @prior_invitation2 = Fabricate(:invitation, email: @invitee_email, user: user2)
          @to_still_preserve_invitation2 = Fabricate(:invitation, email: "charlene@ccc.com", user: user3)
          @prior_invitation3 = Fabricate(:invitation, email: @invitee_email, user: user1)
          @to_still_preserve_invitation3 = Fabricate(:invitation, email: "cory@ccc.com", user: user2)

          @invited_user = Fabricate.build(:user, email: @invitee_email)
          creation_service = UserCreation.new(@invited_user, FlashCreation.new(nil), { stripeToken: "123", invitation_token: @prior_invitation2.token })
          creation_service.create_user
        end

        it "deletes any prior invitations for that invitee email address" do
          expect(Invitation.all).not_to include(@prior_invitation1, @prior_invitation2, @prior_invitation3)
        end

        it "does not delete any invitations for other invitees" do
          expect(Invitation.all).to include(@to_still_preserve_invitation1, @to_still_preserve_invitation2, @to_still_preserve_invitation3)
        end

        it "creates a user record for the invitee" do
          expect(User.find_by_email(@invitee_email)).not_to be_nil
        end
      end # other invitations exist 
    end # valid credit card info

    context "invalid credit card info (unsuccessful charge)" do
      before do
        charge = double('charge', successful?: false, error_message: "Your card was declined.")
        StripeWrapper::Charge.should_receive(:create).and_return(charge)

        @flasher = double('flash')
        @flasher.stub(:set_flash)
        FlashCreation.stub(:new).and_return(@flasher)

        @user = Fabricate.build(:user)

        @creation_service = UserCreation.new(@user, FlashCreation.new(nil), { stripeToken: "123" })
      end

      it "sends a danger type of message creation to the flash handler" do
        expect(@flasher).to receive(:set_flash).with(:danger, kind_of(String))
        @return_value = @creation_service.create_user
      end

      it "returns false" do
        return_value = @creation_service.create_user
        expect(return_value).to eq(false)
      end

      it "does not create a new user" do
        @creation_service.create_user
        expect(User.count).to eq(0)
      end

      it "does not send out any emails" do
        @creation_service.create_user
        expect(ActionMailer::Base.deliveries).to be_empty
      end
    end # invalid credit card info
  end # create_user
end
