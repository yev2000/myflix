class Invitation < ActiveRecord::Base
  belongs_to :user

  validates :email, presence: true
  validates :fullname, presence: true

  def to_param
    return token
  end

  def self.delete_invitations_by_email(email)
    Invitation.delete_all(["email = ?", email])
  end
end
