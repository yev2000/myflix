class VideoQueueEntry < ActiveRecord::Base
  belongs_to :user
  belongs_to :video

  # a video queue entry must have a position to denote where it appears in order
  # for a user's queue.
  validates_presence_of :position
  validates :position, numericality: { greater_than_or_equal_to: 1 }
  
  # The same video cannot appear in a users's queue more than once
  validates_uniqueness_of :video, scope: [:user_id]

end
