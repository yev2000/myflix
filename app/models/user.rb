class User < ActiveRecord::Base
  has_secure_password validations: false

  has_many :reviews, -> { order("created_at DESC") }

  has_many :video_queue_entries
  has_many :sorted_video_queue_entries, -> { order("position") }, class_name: "VideoQueueEntry"
  has_many :queued_videos, -> { order("position") }, {through: :video_queue_entries, source: :video}

  has_many :following_relationships, class_name: "Following", foreign_key: :follower_id
  has_many :followed_relationships, class_name: "Following", foreign_key: :leader_id

  validates :email, presence: true, uniqueness: true, length: {minimum: 3}
  validates :password, presence: true, on: :create, length: {minimum: 4}
  validates :fullname, presence: true

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
