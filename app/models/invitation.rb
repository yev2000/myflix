class Invitation < ActiveRecord::Base
  belongs_to :user

  validates :email, presence: true
  validates :fullname, presence: true

  def to_param
    return token
  end
end
