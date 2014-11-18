class User < ActiveRecord::Base
  MIN_EMAIL_LENGTH = 3
  MIN_PASSWORD_LENGTH = 4

  has_secure_password validations: false

  has_many :reviews, -> { order("created_at DESC") }

  has_many :video_queue_entries
  has_many :sorted_video_queue_entries, -> { order("position") }, class_name: "VideoQueueEntry"
  has_many :queued_videos, -> { order("position") }, {through: :video_queue_entries, source: :video}

  has_many :following_relationships, class_name: "Following", foreign_key: :follower_id
  has_many :followed_relationships, class_name: "Following", foreign_key: :leader_id

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

  def can_follow?(leader)
    # you cannot follow a "nil" leader nor a leader who is yourself nor someone you're already following
    !(leader.nil? || (leader == self) || follows?(leader))
  end

  def follow(leader)
    Following.create(leader_id: leader.id, follower_id: self.id) if can_follow?(leader)
  end

  def followed_leaders
    User.find(following_relationships.pluck(:leader_id))
  end

  def followers
    User.find(followed_relationships.pluck(:follower_id))
  end

  def follows?(another_user)
    followed_leaders.include?(another_user)
  end
end
