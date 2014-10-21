class User < ActiveRecord::Base
  has_secure_password validations: false
  has_many :reviews
  has_many :video_queue_entries
  has_many :queued_videos, -> { order("position") }, {through: :video_queue_entries, source: :video}

  validates :email, presence: true, uniqueness: true, length: {minimum: 3}
  validates :password, presence: true, on: :create, length: {minimum: 4}
  validates :fullname, presence: true

end
