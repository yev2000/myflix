require 'rails_helper'

describe UserCreation do
  describe "#create_user" do
    context "valid credit card info" do
      before do
        charge = double('charge')
        charge.stub(:successful?).and_return(true)
        StripeWrapper::Charge.should_receive(:create).and_return(charge)

        @user = Fabricate.build(:user)
      end

      after { ActionMailer::Base.deliveries.clear }

      context "no invitation_token option supplied" do
        before do
          creation_service = UserCreation.new(@user, { stripeToken: "123" })
          @return_value = creation_service.create_user
        end

        it "returns a successful creation object" do
          expect(@return_value.successful?).to eq(true)
        end

        it "creates a new user" do
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
          @invitation = Fabricate(:invitation, user: @inviter, fullname: "Joe Doe")

          @invited_user = Fabricate.build(:user, email: @invitation.email, fullname: @invitation.fullname)
          creation_service = UserCreation.new(@invited_user, { stripeToken: "123", invitation_token: @invitation.token })
          @return_value = creation_service.create_user

          @inviter.reload
        end
            
        it "returns a successful creation object" do
          expect(@return_value.successful?).to eq(true)
        end

        it "creates a new user" do
          invited_user = User.find_by_email(@invitation.email)
          expect(invited_user).not_to be_nil
          expect(User.count).to eq(2)
        end 

        it "adds a follow relationship between the inviter and invitee user" do
          invited_user = User.find_by_email(@invitation.email)
          expect(invited_user.followers).to eq([@inviter])
        end

        it "adds a follow relationship between the invitee and inviter" do
          invited_user = User.find_by_email(@invitation.email)
          expect(@inviter.followers).to eq([invited_user])
        end

        it "destroys the invitation identified by the invitation token parameter" do
          expect(Invitation.find_by_token(@invitation.token)).to be_nil
          expect(Invitation.count).to eq(0)
        end

        it "sends an email" do
          expect(ActionMailer::Base.deliveries).not_to be_empty
        end

        it "sends an email to the email address of the created user" do
          message = ActionMailer::Base.deliveries.first
          expect(message.to).to eq([@invitation.email])
        end

        it "has a welcome message in the email body" do
          message = ActionMailer::Base.deliveries.first
          if message.parts.size > 0
            message.parts.each do |part|
              expect(part.body).to include("Welcome to MyFlix!")
              expect(part.body).to include(@invited_user.fullname)
            end
          else
            expect(message.body).to include("Welcome to MyFlix!")
            expect(message.body).to include(@invited_user.fullname)
          end
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
          creation_service = UserCreation.new(@invited_user, { stripeToken: "123", invitation_token: @prior_invitation2.token })
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

        @user = Fabricate.build(:user)

        @creation_service = UserCreation.new(@user, { stripeToken: "123" })
        @return_value = @creation_service.create_user
      end

      it "returns an unsuccessful creation object" do
        expect(@return_value.successful?).to eq(false)
      end

      it "sets an error message" do
        expect(@return_value.error_message).not_to be_nil
      end

      it "does not create a new user" do
        expect(User.count).to eq(0)
      end

      it "does not send out any emails" do
        expect(ActionMailer::Base.deliveries).to be_empty
      end
    end # invalid credit card info

    context "invalid user info" do
      context "email already exists" do
        before do
          joe_user = Fabricate(:user, email: "joe@company.com")
          @user = Fabricate.build(:user, email: joe_user.email)

          creation_service = UserCreation.new(@user, { stripeToken: "123" })
          @return_value = creation_service.create_user
        end

        it "fails to create a new user if the email already exists" do
          expect(User.all.size).to eq(1)
        end

        it "returns an object which responds with successful? false" do
          expect(@return_value.successful?).to eq(false)
        end

        it "does not send out a welcome email" do
          expect(ActionMailer::Base.deliveries).to be_empty
        end
      end

      context "email is blank" do
        before do
          @user = Fabricate.build(:user, email: nil)

          creation_service = UserCreation.new(@user, { stripeToken: "123" })
          @return_value = creation_service.create_user
        end

        it "fails to create a new user if the email already exists" do
          expect(User.all.size).to eq(0)
        end

        it "returns an object which responds with successful? false" do
          expect(@return_value.successful?).to eq(false)
        end

        it "does not send out a welcome email" do
          expect(ActionMailer::Base.deliveries).to be_empty
        end
      end
    end # invalid user info

    context "no credit card charge when invalid user info supplied" do
      before do
        charge = double('charge')
        StripeWrapper::Charge.should_not_receive(:create)
      end

      it "it does not charge a credit card when a duplicate email is supplied for user info" do
        joe_user = Fabricate(:user, email: "joe@company.com")
        user = Fabricate.build(:user, email: joe_user.email)

        creation_service = UserCreation.new(user, { stripeToken: "123" })
        creation_service.create_user
      end

      it "it does not charge a credit card when the user's email is not set" do
        user = Fabricate.build(:user, email: nil)

        creation_service = UserCreation.new(user, { stripeToken: "123" })
        creation_service.create_user
      end

    end
  end # create_user
end
