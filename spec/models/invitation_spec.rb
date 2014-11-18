require 'rails_helper'

describe Invitation do
  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:fullname) }
  it { should belong_to(:user) }

  it_behaves_like("tokenable") { let(:object) { Fabricate(:invitation) } }

  describe "#self.delete_invitations_by_email" do
    before do
      to_delete_email = "alice@aaa.com"
      user1 = Fabricate(:user)
      user2 = Fabricate(:user)
      user3 = Fabricate(:user)

      @invitation_to_delete_1 = Fabricate(:invitation, email: to_delete_email, user: user1)
      @to_still_preserve_invitation1 = Fabricate(:invitation, email: "charlie@ccc.com", user: user1)
      @invitation_to_delete_2 = Fabricate(:invitation, email: to_delete_email, user: user2)
      @to_still_preserve_invitation2 = Fabricate(:invitation, email: "charlene@ccc.com", user: user3)
      @invitation_to_delete_3 = Fabricate(:invitation, email: to_delete_email, user: user1)
      @to_still_preserve_invitation3 = Fabricate(:invitation, email: "cory@ccc.com", user: user2)

      Invitation.delete_invitations_by_email(to_delete_email)
    end

    it "deletes all invitations for the specified email" do
      expect(Invitation.all).not_to include([@invitation_to_delete_1, @invitation_to_delete_2, @invitation_to_delete_3])
    end

    it "does not delete invitations for other emails" do
      expect(Invitation.all).to eq([@to_still_preserve_invitation1, @to_still_preserve_invitation2, @to_still_preserve_invitation3])
    end

  end # follow


end
