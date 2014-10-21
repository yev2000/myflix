class VideoQueueEntry < ActiveRecord::Base
  belongs_to :user
  belongs_to :video

  delegate :categories, to: :video

  # a video queue entry must have a position to denote where it appears in order
  # for a user's queue.
  validates_presence_of :position
  validates :position, numericality: { greater_than_or_equal_to: 1 }
  
  # The same video cannot appear in a users's queue more than once
  validates_uniqueness_of :video, scope: [:user_id]

  def review
    # finds the review that was created by this queue entry's user
    # for the queue entry's video.  Returns nil if no such review was
    # found.
    video_review = Review.find_by(video_id: video.id, user_id: user.id)
  end

  def rating_string
    # returns the string representation of a user's review of the video
    # associated with this queue entry
    self.review ? self.review.rating_string : "Not rated"
  end
end
