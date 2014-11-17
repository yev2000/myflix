class Invitation < ActiveRecord::Base
  belongs_to :user

  validates :email, presence: true
  validates :fullname, presence: true

  def to_param
    return token
  end

  def perform_invitation_tasks(user)
    user.add_follow_relationships_from_invitation(self)

    # now delete all invitations that target that email address, since we want to consider
    # that target user as "claimed"
    Invitation.delete_all(["email = ?", self.email])
  end
end
