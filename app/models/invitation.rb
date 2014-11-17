class Invitation < ActiveRecord::Base
  belongs_to :user

  validates :email, presence: true
  validates :fullname, presence: true

  def to_param
    return token
  end

  def ensure_unique_invitation!(inviter)
    self.user = inviter
    self.token = SecureRandom.urlsafe_base64
    if (self.save)
      Invitation.delete_all(["email = ? AND token <> ?", email, token])
      return true
    else
      return false
    end        
  end
end
