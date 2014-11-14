class User < ActiveRecord::Base

  MIN_EMAIL_LENGTH = 3
  MIN_PASSWORD_LENGTH = 4

  has_secure_password validations: false
  has_many :reviews
  has_many :video_queue_entries
  has_many :sorted_video_queue_entries, -> { order("position") }, class_name: "VideoQueueEntry"
  has_many :queued_videos, -> { order("position") }, {through: :video_queue_entries, source: :video}

  validates :email, presence: true, uniqueness: true, length: {minimum: MIN_EMAIL_LENGTH}
  validates :password, presence: true, on: :create, length: {minimum: MIN_PASSWORD_LENGTH}
  validates :fullname, presence: true

  def password_sufficient?(password_candidate, set_errors=false)
    # allows in the future for more complex logic
    # in terms of password strength
    if (password_candidate && password_candidate.length >= MIN_PASSWORD_LENGTH)
      return true
    else
      errors.add(:password, "Your password must be at least #{MIN_PASSWORD_LENGTH} characters.") if set_errors
      return false
    end
  end

end
