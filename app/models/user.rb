class User < ActiveRecord::Base
  has_secure_password validations: false

  has_many :reviews, -> { order("created_at DESC") }

  has_many :video_queue_entries
  has_many :sorted_video_queue_entries, -> { order("position") }, class_name: "VideoQueueEntry"
  has_many :queued_videos, -> { order("position") }, {through: :video_queue_entries, source: :video}

  has_many :following_relationships, class_name: "Following", foreign_key: :follower_id
  
  validates :email, presence: true, uniqueness: true, length: {minimum: 3}
  validates :password, presence: true, on: :create, length: {minimum: 4}
  validates :fullname, presence: true

  def followers
    User.find(Following.where(leader: self.id).pluck(:follower_id))
  end
end
